# nftables Source and Documentation Map (Where Constraints Come From)

Use this file when you need to trace a rule constraint back to official documentation or userspace implementation details.

## 1) Official Userspace Source (`nft` CLI, Parser, Evaluator)

- Project root: `https://git.netfilter.org/nftables/`
- `src/` directory: `https://git.netfilter.org/nftables/tree/src`

Key files:

- `src/parser_bison.y`
  - Bison grammar for nft syntax
  - https://git.netfilter.org/nftables/tree/src/parser_bison.y
- `src/scanner.l`
  - Flex lexer / tokenizer
  - https://git.netfilter.org/nftables/tree/src/scanner.l
- `include/parser.h`
  - parser state and parser/scanner interfaces
  - https://git.netfilter.org/nftables/tree/include/parser.h
- `src/evaluate.c`
  - userspace semantic checks (many constraints in this skill come from here)
  - family/hook validation, chain checks, protocol-context conflicts, `inet` restrictions
  - https://git.netfilter.org/nftables/tree/src/evaluate.c
- `src/netlink_linearize.c`
  - AST -> netlink linearization
  - https://git.netfilter.org/nftables/tree/src/netlink_linearize.c
- `src/netlink_delinearize.c`
  - netlink -> human-readable ruleset conversion
  - https://git.netfilter.org/nftables/tree/src/netlink_delinearize.c
- `src/libnftables.c`
  - embeddable API entry path
  - https://git.netfilter.org/nftables/tree/src/libnftables.c

## 2) Official Docs in the `nftables` Source Tree (Primary for Constraints)

These are usually better than wiki pages for exact statement/hook constraints.

- `doc/nft.txt`
  - CLI options (`--check`, `--debug`)
  - family/chain/hook semantics
  - verdict behavior (`queue`, etc.)
  - https://git.netfilter.org/nftables/tree/doc/nft.txt
- `doc/statements.txt`
  - `dnat`, `snat`, `masquerade`, `redirect`, `reject`, `tproxy`, and more
  - https://git.netfilter.org/nftables/tree/doc/statements.txt
- `doc/payload-expression.txt`
  - payload expressions and protocol-dependent matching
  - https://git.netfilter.org/nftables/tree/doc/payload-expression.txt

## 3) Kernel Side (`nf_tables`) Is the Final Authority

- Userspace (`nft`) validates and compiles rules, but the kernel decides final support.
- If a ruleset passes `nft -c` but fails to load/apply, investigate kernel version/module support.

Reference development tree:

- netfilter `nf-next`: `https://git.kernel.org/cgit/linux/kernel/git/netfilter/nf-next.git`

## 4) Useful Search Keywords (Fast Constraint Tracing)

Search these in `src/evaluate.c`:

- `unsupported hook`
- `unknown chain hook`
- `device only valid in ingress/egress chains`
- `missing { device } in this chain definition`
- `conflicting protocols specified`
- `meta nfproto is only useful in the inet family`
- `ip or ip6 must be specified with address for inet tables`

Search these in `doc/statements.txt`:

- `DNAT statement`
- `SNAT statement`
- `Masquerade statement`
- `Redirect statement`
- `REJECT STATEMENT`
- `TPROXY STATEMENT`

Search these in `doc/nft.txt`:

- `--check`
- `--debug`
- `CHAINS`
- `VERDICT STATEMENTS`
- `queue`

## 5) Where Wiki Fits (Useful, but Not the Only Source)

The wiki is good for:

- examples
- quick syntax reminders
- beginner-friendly walkthroughs

Do not rely on wiki alone for strict legality constraints:

- content may lag the userspace implementation
- hook/chain/family restrictions may be incomplete for your use case

Example wiki page source (MediaWiki raw text):

- `https://wiki.nftables.org/wiki-nftables/index.php?action=raw&title=Quick_reference-nftables_in_10_minutes`

