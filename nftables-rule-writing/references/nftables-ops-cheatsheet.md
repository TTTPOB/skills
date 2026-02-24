# nftables Ops Cheatsheet (Runtime, Persistence, Service Integration)

Use this file for operational tasks after rules are written: validate, apply, inspect, persist, and debug what is actually active.

## 1. Core Commands (Daily Use)

```bash
# Validate only (no apply)
sudo nft -c -f /etc/nftables.conf

# Validate with debug details
sudo nft -c -d parser,eval,netlink -f /etc/nftables.conf

# Apply ruleset
sudo nft -f /etc/nftables.conf

# List active ruleset
sudo nft list ruleset

# List active ruleset with handles
sudo nft -a list ruleset

# Flush all active rules
sudo nft flush ruleset
```

## 2. Safe Edit / Apply Loop

Recommended workflow:

1. Save current active ruleset (backup)
2. Edit candidate file
3. Run `nft -c -f <file>`
4. Apply only if validation passes
5. Re-list active ruleset and verify expected chains/rules exist

Example:

```bash
sudo nft list ruleset > /root/nft.backup.$(date +%Y%m%d-%H%M%S).nft
sudo nft -c -f /etc/nftables.conf
sudo nft -f /etc/nftables.conf
sudo nft -a list ruleset
```

## 3. Runtime Inspection (What Is Actually Active?)

```bash
# Full active ruleset
sudo nft list ruleset

# Specific table
sudo nft list table inet filter

# Specific chain
sudo nft list chain inet filter input

# Rule counters / handles (via table/chain listing depending on version/output)
sudo nft -a list chain inet filter input
```

## 4. Logging and Monitoring

```bash
# Check whether logging rules exist
sudo nft list ruleset | grep -n "log"

# Kernel log view (common)
sudo journalctl -k -f

# Prefix-specific filter (example)
sudo journalctl -k -f | grep "nft-drop"

# Generic nft monitor (events)
sudo nft monitor
```

Notes:

- Log output path varies by distro/systemd-journald/syslog configuration.
- Use explicit log prefixes in rules for easier filtering.

## 5. Persistence: Do Not Assume `/etc/nftables.conf` Is the Only Source

Many systems use `nftables.service` with `/etc/nftables.conf`, but custom services, drop-ins, generated units, or app-specific systemd services may load their own `.nft` files or call `nft` directly.

Always inspect the service path that actually loads rules.

## 6. systemd Persistence Discovery (Scan Units and Drop-Ins)

### 6.1 Common systemd unit directories to scan

- `/etc/systemd/system` (local/admin overrides)
- `/run/systemd/system` (runtime-generated units/drop-ins)
- `/usr/lib/systemd/system` (most distro package units)
- `/lib/systemd/system` (some distros)

### 6.2 Fast search for `nft`, `nftables`, or `.nft` references

```bash
sudo rg -n -i \
  -g '*.service' -g '*.socket' -g '*.timer' -g '*.path' -g '*.target' -g '*.conf' \
  '(nftables?|\\.nft\\b|Exec(Start|Reload|Stop).*=.*nft\\b)' \
  /etc/systemd/system /run/systemd/system /usr/lib/systemd/system /lib/systemd/system 2>/dev/null
```

This catches:

- direct `ExecStart=/usr/sbin/nft -f ...`
- unit/drop-in mentions of `.nft` files
- references to `nftables` wrappers/scripts

### 6.3 Inspect discovered units fully (including drop-ins)

```bash
systemctl cat nftables.service
systemctl cat <your-custom-unit>.service
```

Why this matters:

- `systemctl cat` shows both the base unit and all applied drop-ins, which often contain the real override path.

### 6.4 Inspect service state and startup order

```bash
systemctl status nftables.service
systemctl is-enabled nftables.service
systemctl list-dependencies --reverse nftables.service
```

Use this to find:

- whether a wrapper service depends on `nftables.service`
- whether another service reapplies rules later in boot

## 7. Check for Tool Conflicts / Multiple Rule Sources

```bash
# nftables service
systemctl status nftables.service

# Legacy iptables services (names vary by distro)
systemctl status iptables 2>/dev/null || true
systemctl status netfilter-persistent 2>/dev/null || true

# Active nft ruleset
sudo nft list ruleset

# Active iptables rules (if compatibility layer or legacy tooling is in play)
sudo iptables -L -v -n 2>/dev/null || true
```

Why:

- The problem is often not rule syntax but "another service loaded another ruleset later."

## 8. Emergency Rollback (Operational)

Use only with console access or safe fallback path.

```bash
# Flush current rules (temporary emergency)
sudo nft flush ruleset

# Reload known-good backup
sudo nft -f /root/nft.backup.YYYYMMDD-HHMMSS.nft
```

If the host is managed by systemd service persistence:

```bash
sudo systemctl restart nftables.service
sudo systemctl status nftables.service
```

## 9. Quick Persistence Checklist

- Validate target file with `nft -c` before reload
- Confirm which systemd unit actually loads nft rules
- Check `systemctl cat` for drop-ins and overridden `ExecStart`
- Scan common systemd dirs for `.nft` references and `nft` invocations
- Confirm no other firewall services overwrite the rules later
- Re-list active ruleset after restart/reboot path changes

