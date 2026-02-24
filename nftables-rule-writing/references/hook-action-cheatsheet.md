# Hook / Action Cheatsheet (Fast Triage)

This is the fast path for catching common invalid rule placements.

## NAT Actions (Require `type nat` Chains)

| Action | Common Valid Hooks | Common Mistakes |
|---|---|---|
| `dnat` | `prerouting`, `output` | Put in `filter` chain; put in `postrouting` |
| `snat` | `postrouting`, `input` (per nft docs) | Put in `filter` chain; put in `prerouting` |
| `masquerade` | `postrouting` | Put in `prerouting` / `output` |
| `redirect` | `prerouting`, `output` | Put in `postrouting` |

Reminder:

- In `table inet`, `dnat` / `snat` with an address must specify `ip` or `ip6`.

## Other Actions with Important Constraints

| Action | Key Constraint |
|---|---|
| `reject` | Not valid on every hook; supported only on specific base-chain hooks (and regular chains reached from them) |
| `tproxy` | Only `ip`/`ip6`/`inet`; requires transport-header context (`tcp`/`udp`); not a terminal statement |
| `queue` | Control flow is often misunderstood; reinject behavior is not "continue next rule" |

## `ingress` / `device` Reminder

| Scenario | `device` Required? |
|---|---|
| `table netdev` base chain | Yes |
| `table inet` + `hook ingress` | Yes |
| Non-`ingress`/`egress` hooks | Do not use `device` |

## `table inet` Dual-Stack Reminder

| Situation | Recommended Pattern |
|---|---|
| Need both IPv4 and IPv6 support | Prefer separate rules (`ip ...` and `ip6 ...`) |
| Need shared structure | Use `meta nfproto` split, then family-specific payload matches |
| NAT with explicit address | Write `dnat ip to ...` or `dnat ip6 to ...` |
| ICMP | Use `icmp` for IPv4, `icmpv6` for IPv6; `icmpx` is common in `reject` on `inet` |

## 30-Second Review Order

1. `table` family
2. chain `type + hook`
3. `device` (missing when required, or present where invalid)
4. action legality for that hook
5. `inet` IPv4/IPv6 mixing
6. `nft -c -f <file>`
