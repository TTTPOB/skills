# Common nftables Pitfalls (LLM-Generated Rules)

This file focuses on high-frequency mistakes seen in generated rulesets.

Format:

- Bad pattern
- Why it fails or is risky
- Corrected pattern

## 1. NAT Action Inside a `filter` Chain

Bad:

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;
        tcp dport 80 dnat ip to 192.0.2.10
    }
}
```

Why:

- `dnat` is a NAT statement and belongs in a `type nat` base chain.

Good:

```nft
table inet nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 80 dnat ip to 192.0.2.10
    }
}
```

## 2. `masquerade` on the Wrong Hook

Bad:

```nft
table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        masquerade
    }
}
```

Why:

- `masquerade` is for `postrouting` in `type nat` chains.

Good:

```nft
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname "eth0" masquerade
    }
}
```

## 3. `redirect` on `postrouting`

Bad:

```nft
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        tcp dport 80 redirect to :8080
    }
}
```

Why:

- `redirect` is supported on `prerouting` and `output` NAT hooks, not `postrouting`.

Good:

```nft
table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 80 redirect to :8080
    }
}
```

## 4. `table inet` NAT Address Without `ip` / `ip6`

Bad:

```nft
table inet nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 80 dnat to 192.0.2.10
    }
}
```

Why:

- In `table inet`, address-bearing `dnat`/`snat` requires explicit family prefix.

Good:

```nft
tcp dport 80 dnat ip to 192.0.2.10
```

IPv6 example:

```nft
tcp dport 80 dnat ip6 to 2001:db8::10
```

## 5. Mixing `ip` and `ip6` Payload Matches in One Rule

Bad:

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ip saddr 192.0.2.0/24 ip6 daddr 2001:db8::/32 accept
    }
}
```

Why:

- This creates a conflicting protocol context in a single rule.

Good (recommended):

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ip saddr 192.0.2.0/24 accept
        ip6 daddr 2001:db8::/32 accept
    }
}
```

## 6. Missing `device` in `netdev` Base Chain

Bad:

```nft
table netdev filter {
    chain ingress {
        type filter hook ingress priority 0; policy accept;
        tcp dport 22 drop
    }
}
```

Why:

- `netdev` base chains require `device`.

Good:

```nft
table netdev filter {
    chain ingress_eth0 {
        type filter hook ingress device "eth0" priority 0; policy accept;
        tcp dport 22 drop
    }
}
```

## 7. Missing `device` in `table inet` `hook ingress`

Bad:

```nft
table inet filter {
    chain ingress {
        type filter hook ingress priority 0; policy accept;
    }
}
```

Why:

- `inet` ingress base chains also require `device`.

Good:

```nft
table inet filter {
    chain ingress_eth0 {
        type filter hook ingress device "eth0" priority 0; policy accept;
    }
}
```

## 8. `reject` on Unsupported Hooks

Bad (conceptual example):

```nft
table ip filter {
    chain postrouting {
        type filter hook postrouting priority 0; policy accept;
        reject
    }
}
```

Why:

- `reject` is not supported on every hook.

Fix:

- Move the logic to a supported hook (for example `input`, `forward`, `output`, `prerouting` as documented), or
- Use `drop` if silent discard is acceptable.

## 9. `tproxy` Without Transport Context

Bad:

```nft
tproxy to :3129
```

Why:

- `tproxy` requires a match that ensures the transport header exists.

Good:

```nft
tcp dport 80 tproxy to :3129
udp dport 53 tproxy to :1053
```

## 10. Misunderstanding `queue` Control Flow

Common incorrect assumption:

- "After userspace reinjects `accept`, processing continues at the next rule in the same chain."

Why this matters:

- This can produce incorrect policy flow designs and misleading explanations.

Reality (per docs):

- Reinjected `accept` continues at the next base-chain hook, not the next rule in the current chain.

## 11. Mixing `icmp` and IPv6 Context in `table inet`

Bad:

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        icmp type echo-request ip6 saddr 2001:db8::/32 accept
    }
}
```

Why:

- `icmp` is IPv4 ICMP. IPv6 ICMP matches use `icmpv6`.

Good:

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        icmp type echo-request accept
        icmpv6 type echo-request accept
    }
}
```

## 12. Overusing Ambiguous Shorthand in Generated Rules

Risky:

```nft
th dport 443 accept
```

Why:

- It can be valid in some contexts, but generated rules become harder to review and easier to get wrong when protocol context is unclear.

Safer generated form:

```nft
tcp dport 443 accept
udp dport 443 accept
```

## Quick Review Checklist (Agent-Focused)

If any of these tokens appear, trigger a targeted legality check:

- `dnat`
- `snat`
- `masquerade`
- `redirect`
- `reject`
- `tproxy`
- `queue`
- `hook ingress`
- `table inet`
- both `ip ` and `ip6 ` in the same rule

