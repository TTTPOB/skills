# nftables Troubleshooting (Operational + Semantic)

Use this file for real-world failures after or during deployment. This complements `debug-workflow.md` (which is more parser/eval-focused).

## 1. Triage by Symptom

## A. `nft -c -f` fails

Likely categories:

- syntax/parser error
- userspace semantic constraint error (hook/family/statement/protocol context)

Open next:

- `debug-workflow.md`
- `constraints-matrix.md`
- `common-pitfalls.md`

## B. `nft -c -f` passes but `nft -f` / service start fails

Likely categories:

- kernel/version/module support issue
- service loads a different file than expected
- another unit/service mutates rules later

Open next:

- `nftables-ops-cheatsheet.md` (persistence/service scan)
- `source-map.md` (if validating a constraint claim)

## C. Service is active but behavior is wrong

Likely categories:

- wrong chain/hook path for actual traffic
- ruleset was replaced after boot by another service
- logging/observability missing
- iptables/nftables mixed environment confusion

## 2. "Rules Are Not What I Applied" (Very Common)

Do not assume the source of truth is `/etc/nftables.conf`.

### 2.1 Confirm active kernel ruleset

```bash
sudo nft -a list ruleset
```

### 2.2 Inspect `nftables.service` and overrides

```bash
systemctl cat nftables.service
systemctl status nftables.service
```

### 2.3 Scan common systemd unit directories for nft references

This finds custom services, wrappers, or drop-ins that call `nft` or reference `.nft` files.

```bash
sudo rg -n -i \
  -g '*.service' -g '*.socket' -g '*.timer' -g '*.path' -g '*.target' -g '*.conf' \
  '(nftables?|\\.nft\\b|Exec(Start|Reload|Stop).*=.*nft\\b)' \
  /etc/systemd/system /run/systemd/system /usr/lib/systemd/system /lib/systemd/system 2>/dev/null
```

### 2.4 Inspect any hits with `systemctl cat`

```bash
systemctl cat <hit-unit>.service
```

Why:

- Drop-ins often override `ExecStart` and point to a different `.nft` file.

## 3. "Rules Load but Traffic Is Still Allowed/Blocked"

Checklist:

1. Confirm service/process is actually listening:
   - `ss -tuln`
2. Confirm packet path reaches the chain/hook you edited:
   - `input`, `forward`, `output`, `prerouting`, `postrouting`, `ingress`
3. Confirm rule order and counters:
   - `nft -a list chain ...`
4. Confirm no later service overwrote rules:
   - see systemd scan above
5. Confirm logging exists for the decision path:
   - `log prefix ...`

## 4. "Logging Not Working"

Checks:

```bash
# Verify logging rules exist
sudo nft list ruleset | grep -n "log"

# Kernel journal
sudo journalctl -k -f

# Prefix filter example
sudo journalctl -k -f | grep "nft-drop"
```

Notes:

- Missing logs may mean the packet never reaches that chain/rule.
- Add rate-limited logging before terminal verdicts when debugging.

## 5. "nftables Service Starts, Then Rules Change Later"

This usually means another service or script runs after boot.

Investigate:

```bash
# Look for units related to networking/firewall startup ordering
systemctl list-dependencies multi-user.target

# Search systemd unit files and drop-ins for nft invocations
sudo rg -n -i \
  -g '*.service' -g '*.conf' \
  '(nftables?|\\.nft\\b|Exec(Start|Reload|Stop).*=.*nft\\b)' \
  /etc/systemd/system /run/systemd/system /usr/lib/systemd/system /lib/systemd/system 2>/dev/null
```

Then:

- inspect suspicious units with `systemctl cat`
- inspect timers that may periodically re-apply rules
- inspect distro/network-management services if they run custom hooks/scripts

## 6. "Mixed Firewall Tooling" Confusion

Symptoms:

- unexpected behavior
- rules present in one tool but not reflected in runtime behavior as expected

Checks:

```bash
systemctl status nftables.service
systemctl status iptables 2>/dev/null || true
systemctl status netfilter-persistent 2>/dev/null || true

sudo nft list ruleset
sudo iptables -L -v -n 2>/dev/null || true
```

Response pattern:

- identify the intended authority (nftables vs legacy tooling)
- disable/stop conflicting services if appropriate
- reapply and re-verify the intended ruleset

## 7. Support Bundle (What to Ask the User For)

When remote-debugging a host, ask for:

- `nft --version`
- `uname -r`
- `sudo nft -a list ruleset`
- `systemctl cat nftables.service`
- output of the systemd unit scan command above
- the candidate `.nft` file they intended to load
- exact error output from `sudo nft -c -f <file>`

