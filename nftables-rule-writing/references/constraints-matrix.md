# nftables Constraint Matrix (Docs + Source-Informed)

Use this file when a rule looks syntactically correct but may be invalid for a specific family, chain type, hook, or protocol context.

## How to Use This Matrix

Check in this order:

1. Is the `family` compatible with the `hook`?
2. Is the chain a base chain (some statements require it)?
3. Is the statement valid on that chain type / hook?
4. In `table inet`, did the rule explicitly separate IPv4 vs IPv6 where needed?
5. Is there a protocol-context conflict (`ip` and `ip6` in one rule)?

## A. Chain / Hook / Family Constraints

### A1. `type route` is for the output path

- `route` chains are for output-path processing.
- Treat `type route` on non-`output` hooks as a design smell and likely invalid usage.

Source basis:

- `doc/nft.txt` (chain type description)

### A2. NAT actions belong in `type nat` base chains

- `dnat`, `snat`, `masquerade`, `redirect` are NAT statements.
- Do not place NAT statements in `type filter` chains.

Source basis:

- `doc/statements.txt` (NAT / redirect statements)

### A3. `netdev` base chains require `device`

- In `family netdev`, a base chain definition must include `device`.

Source basis:

- `src/evaluate.c` (`chain_evaluate()` error text includes `missing { device } in this chain definition`)

### A4. `device` is only valid on `ingress` / `egress` chains

- `device` is not a generic chain attribute.
- Using `device` on `input`, `forward`, `output`, `prerouting`, or `postrouting` is invalid.

Source basis:

- `src/evaluate.c` (`device only valid in ingress/egress chains`)

### A5. `table inet` + `hook ingress` also requires `device`

- `inet` family supports `ingress` on newer kernels (documented in `nft` docs).
- If you define an `inet` base chain on `hook ingress`, include `device`.

Source basis:

- `doc/nft.txt` (`inet` ingress support notes)
- `src/evaluate.c` (`missing { device } in this chain definition`)

### A6. Family/hook combinations are checked in userspace

- `nft` userspace validates whether the hook is supported for the selected family.
- Invalid combinations fail during semantic evaluation.

Source basis:

- `src/evaluate.c`
  - `str2hooknum()`
  - `chain_evaluate()` (`unsupported hook`, `unknown chain hook`)

## B. Statement Constraints by Hook / Chain Type

### B1. `dnat`

- Valid/meaningful in `prerouting` and `output` hooks of `type nat` chains.
- Do not use in `filter` chains.

Source basis:

- `doc/statements.txt` (`DNAT statement`)

### B2. `snat`

- Valid/meaningful in `postrouting` and `input` hooks of `type nat` chains (per nft docs text).

Source basis:

- `doc/statements.txt` (`SNAT statement`)

### B3. `masquerade`

- Supported only in `postrouting` hook of `type nat` chains.

Source basis:

- `doc/statements.txt` (`Masquerade statement`)

### B4. `redirect`

- Supported only in `prerouting` and `output` hooks of `type nat` chains.

Source basis:

- `doc/statements.txt` (`Redirect statement`)

### B5. `reject`

- `reject` is supported only on specific hooks in base chains:
  - `prerouting`
  - `input`
  - `forward`
  - `output`
- It also applies in regular chains reached from those base chains.
- `bridge` family is stricter (docs limit it further).

Source basis:

- `doc/statements.txt` (`REJECT STATEMENT`)

### B6. `tproxy`

Important constraints:

- Supported only for `ip`, `ip6`, and `inet`
- Not a terminal statement
- Address and port ranges are not supported
- Requires another match to guarantee transport-header presence (typically `tcp` or `udp`)

Source basis:

- `doc/statements.txt` (`TPROXY STATEMENT`)

### B7. `queue` control flow is easy to misstate

- `queue` is a verdict statement.
- After userspace reinjection with `accept`, evaluation continues at the next base-chain hook, not the next rule in the current chain.

Source basis:

- `doc/nft.txt` (verdict and `queue` behavior)

## C. `table inet` Dual-Stack Constraints (IPv4/IPv6)

### C1. `inet` NAT addresses require explicit `ip` or `ip6`

In `table inet`, if `dnat`/`snat` includes an address, specify the family explicitly:

- `dnat ip to 192.0.2.10`
- `dnat ip6 to 2001:db8::10`

Source basis:

- `src/evaluate.c` error text: `ip or ip6 must be specified with address for inet tables.`

### C2. Conflicting protocol contexts are rejected

Typical bad pattern:

- Mixing `ip ...` and `ip6 ...` payload matches in the same rule

Userspace semantic checks can fail with messages like:

- `conflicting protocols specified: ... vs ...`

Source basis:

- `src/evaluate.c`

### C3. `meta nfproto` is mainly useful in `inet`

- In non-`inet` families, `meta nfproto` is usually not useful.
- `src/evaluate.c` includes a diagnostic for this.

Recommended use:

- In `table inet`, if you truly need a shared rule shape, split by `meta nfproto` first, then use family-specific payload expressions.
- Otherwise, prefer two separate rules.

Source basis:

- `src/evaluate.c` (`meta nfproto is only useful in the inet family`)

### C4. `icmp` vs `icmpv6` vs `icmpx`

- `icmp` matches IPv4 ICMP
- `icmpv6` matches IPv6 ICMP
- `icmpx` is often used with `reject` in `inet` family rules

Source basis:

- `doc/payload-expression.txt`
- `doc/statements.txt` (`reject ... icmpx ...`)

## D. Payload / Protocol-Dependency Pitfalls

### D1. Some payload expressions imply protocol dependencies

- Many payload fields assume a protocol header exists.
- LLMs often emit fields without establishing protocol context first.

Safer authoring pattern:

- Prefer explicit protocol context:
  - `tcp dport ...`
  - `udp dport ...`
  - `icmp type ...`
  - `icmpv6 type ...`

Source basis:

- `doc/payload-expression.txt`

### D2. `tproxy` is especially sensitive to transport-header context

- The docs explicitly require another rule/match ensuring the transport header exists.
- Bare `tproxy to ...` is a common invalid pattern.

Source basis:

- `doc/statements.txt` (`TPROXY STATEMENT`)

## E. Version / Environment Caveats (Always State These)

Do not present these as universally static facts without caveats:

- `inet` `ingress` support depends on kernel version
- Module/feature availability depends on kernel config and loaded modules
- Some failures happen in userspace semantic checks, others only when applying to the kernel

Recommended wording in reviews:

- "This was checked against documented nftables constraints; final validation still requires `nft -c -f` (and, if needed, actual load testing) on the target host."

