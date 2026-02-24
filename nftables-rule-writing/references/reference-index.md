# Reference Index (What to Open for What Task)

Use this file as the entry point when the skill is triggered.

## If the User Wants a New Ruleset

Open in this order:

1. `quickstart.md`
2. `nftables-patterns.md`
3. `hook-action-cheatsheet.md`
4. `constraints-matrix.md` (only for advanced features or special hooks)
5. `../examples/nftables/` (pick the closest example and adapt it)

## If the User Wants a Review / Lint of LLM-Generated Rules

Open in this order:

1. `hook-action-cheatsheet.md`
2. `common-pitfalls.md`
3. `constraints-matrix.md`
4. `debug-workflow.md` (if error output is provided)
5. `nftables-troubleshooting.md` (if behavior is wrong after load)

## If the User Has an `nft -c` / `nft -f` Error

Open in this order:

1. `debug-workflow.md`
2. `constraints-matrix.md`
3. `common-pitfalls.md`
4. `nftables-ops-cheatsheet.md` (service/persistence/runtime checks)
5. `nftables-troubleshooting.md`
6. `source-map.md` (to verify with official docs/source)

## If the User Asks About Persistence / What Loads Rules at Boot

Open:

1. `nftables-ops-cheatsheet.md` (systemd unit + drop-in scan)
2. `nftables-troubleshooting.md`
3. `quickstart.md` (only if they also need a baseline config)

## If the User Asks "Where Is This Defined?"

Open:

1. `source-map.md`
2. Then search official files listed there (`doc/*.txt`, `src/evaluate.c`)

## If the User Is Confused About `inet` IPv4/IPv6 Rules

Open:

1. `common-pitfalls.md` (dual-stack examples)
2. `constraints-matrix.md` section C (`inet` family constraints)
3. `hook-action-cheatsheet.md` (`inet` reminders)

## If the User Mentions `ingress`, `netdev`, or `device`

Open:

1. `hook-action-cheatsheet.md`
2. `constraints-matrix.md` section A (chain/hook/device constraints)

## If the User Needs Day-2 Operations (Reloads, Monitoring, Rollback)

Open:

1. `nftables-ops-cheatsheet.md`
2. `nftables-troubleshooting.md`
3. `../examples/nftables/` (if they need a safer known-good baseline)
