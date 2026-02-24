# nftables Quickstart (Agent-Oriented)

Use this file when you need a safe starting point before adding custom rules.

## Quickstart Ruleset: Minimal Host Firewall (`table inet filter`)

This is a conservative baseline for a single host (not a router).

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif "lo" accept
        ct state established,related accept
        ct state invalid drop

        # ICMP / ICMPv6 (adjust as needed)
        icmp type echo-request accept
        icmpv6 type echo-request accept

        # Common services (example)
        tcp dport 22 accept
        tcp dport { 80, 443 } accept

        # Optional debugging
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

## Quickstart NAT Skeleton (Separate `nat` Table)

Use a `type nat` base chain for NAT statements. Do not put NAT actions into `type filter` chains.

```nft
table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        # Example:
        # tcp dport 80 dnat to 192.0.2.10
    }

    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        # Example:
        # oifname "eth0" masquerade
    }
}
```

## Quickstart `inet` NAT Reminder

If you use `table inet` with `dnat`/`snat` and specify an address, explicitly write `ip` or `ip6`.

Examples:

```nft
dnat ip to 192.0.2.10
dnat ip6 to 2001:db8::10
snat ip to 198.51.100.5
```

## Quickstart Validation

Before applying:

```bash
nft -c -f /etc/nftables.conf
```

For more detail:

```bash
nft -c -d parser,eval,netlink -f /etc/nftables.conf
```

## Quickstart Persistence Note (systemd)

Do not assume `/etc/nftables.conf` is the only persisted source on every system.

Before relying on a reboot/restart workflow, verify which systemd unit (and drop-ins) actually loads rules:

```bash
systemctl cat nftables.service
sudo rg -n -i \
  -g '*.service' -g '*.conf' \
  '(nftables?|\\.nft\\b|Exec(Start|Reload|Stop).*=.*nft\\b)' \
  /etc/systemd/system /run/systemd/system /usr/lib/systemd/system /lib/systemd/system 2>/dev/null
```

For full operational guidance, open `nftables-ops-cheatsheet.md`.

## When Not to Use This Template

- Router/firewall appliance with forwarding/NAT policy design
- `netdev` ingress filtering (requires `device` and different design)
- `bridge` family filtering
- Transparent proxy (`tproxy`) rulesets

Open next:

- `hook-action-cheatsheet.md` for hook/action constraints
- `nftables-patterns.md` for reusable patterns and richer examples
- `constraints-matrix.md` for detailed legality checks
- `common-pitfalls.md` for LLM-generated mistakes
