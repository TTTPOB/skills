# nftables Patterns (Reusable Rule Structures)

Use this file for practical, reusable examples beyond the minimal quickstart.

These patterns are intentionally conservative and readable for agent generation/review.

## 1. Web Server Host (Dual-Stack, Basic Hardening)

Goals:

- default drop inbound
- allow loopback
- allow established/related
- allow SSH + HTTP/HTTPS
- rate-limited logging

Pattern:

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif "lo" accept
        ct state established,related accept
        ct state invalid drop

        icmp type echo-request accept
        icmpv6 type echo-request accept

        tcp dport 22 accept
        tcp dport { 80, 443 } accept

        log prefix "nft-drop: " limit rate 5/minute level info
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

## 2. SSH Allowlist with a Set (IPv4 Example)

Use a set when multiple addresses/ranges are allowed.

Pattern:

```nft
table inet filter {
    set ssh_allowed_v4 {
        type ipv4_addr
        flags interval
        elements = { 203.0.113.0/24, 198.51.100.10 }
    }

    chain input {
        type filter hook input priority 0; policy drop;

        iif "lo" accept
        ct state established,related accept

        tcp dport 22 ip saddr @ssh_allowed_v4 ct state new limit rate 5/minute accept
    }
}
```

Notes:

- Split IPv4 and IPv6 allowlists into separate sets (`ipv4_addr` / `ipv6_addr`) in `table inet`.
- Avoid forcing both families into one rule if readability suffers.

## 3. Basic Router NAT (IPv4)

Goals:

- forward LAN -> WAN
- allow established return traffic
- masquerade on egress

Pattern:

```nft
table ip filter {
    chain forward {
        type filter hook forward priority 0; policy drop;

        ct state established,related accept
        iifname "lan0" oifname "wan0" accept
    }
}

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname "wan0" masquerade
    }
}
```

Notes:

- This is a minimal pattern; production routers usually need input-chain policy and explicit management access rules.
- NAT statements belong in the `nat` table/chain, not `filter`.

## 4. Port Forwarding (DNAT) + Matching Forward Policy

Common mistake:

- Add `dnat` but forget matching `forward` allow rule.

Pattern:

```nft
table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 443 dnat to 192.0.2.10:443
    }
}

table ip filter {
    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state established,related accept
        ip daddr 192.0.2.10 tcp dport 443 accept
    }
}
```

## 5. `table inet` NAT with Explicit Family Prefix

Pattern:

```nft
table inet nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        tcp dport 80 dnat ip to 192.0.2.10
        tcp dport 80 dnat ip6 to 2001:db8::10
    }
}
```

Why this pattern matters:

- In `table inet`, address-bearing NAT statements must explicitly specify `ip` or `ip6`.

## 6. Logging Pattern (Rate-Limited)

Pattern:

```nft
log prefix "nft-drop: " limit rate 5/minute level info
drop
```

Notes:

- Use a stable prefix for `journalctl -k | grep ...`
- Rate limit logging to avoid flooding

## 7. Egress Allowlist (Host)

This pattern is useful for locked-down servers.

Pattern:

```nft
table inet filter {
    chain output {
        type filter hook output priority 0; policy drop;

        oif "lo" accept
        ct state established,related accept

        # DNS
        udp dport 53 accept
        tcp dport 53 accept

        # NTP
        udp dport 123 accept

        # HTTPS for updates/APIs
        tcp dport 443 accept
    }
}
```

Notes:

- This is intentionally strict; many applications require additional outbound ports/protocols.
- Add logging during rollout to avoid silent breakage.

## 8. Includes / Modular Rulesets (Reference Pattern)

Modular layouts can improve maintainability, but the exact include strategy depends on distro/package defaults.

Recommendations:

- Keep one validated top-level entry file
- Group by table purpose (`filter`, `nat`)
- Group by host role (web, bastion, router)
- Validate the final rendered/loaded file path with `nft -c`

## 9. Pattern Selection Guide

Start here:

- Single host web/API server -> Pattern 1 + Pattern 6
- Restricted SSH admin host -> Pattern 2 + Pattern 6
- Router/gateway -> Pattern 3 (+ Pattern 4 if port forwarding needed)
- Dual-stack NAT in `inet` table -> Pattern 5
- Locked-down outbound host -> Pattern 7

Then validate:

- `nft -c -f <candidate-file>`
- `nft -a list ruleset` after apply

