# nftables Debug and Validation Workflow

Use this file when the user already has a ruleset (or error output) and wants diagnosis.

## 1. Start with Static Validation (Do Not Apply Rules Yet)

```bash
nft -c -f /path/to/rules.nft
```

Why:

- `-c` / `--check` validates without committing changes.
- This is the safest first step for reviewing generated rules.

## 2. Turn On Debug Categories When the Cause Is Unclear

```bash
nft -c -d parser,eval,netlink -f /path/to/rules.nft
```

What each category helps with:

- `parser`: token/grammar issues
- `eval`: userspace semantic checks (hook/family/statement/context constraints)
- `netlink`: linearization / netlink path visibility

## 3. Build a Minimal Reproduction (Strongly Recommended)

Do not debug a large ruleset first.

Workflow:

1. Create a new file with only:
   - one table
   - one chain
   - one failing rule
2. Make the minimal file pass `nft -c`
3. Merge the fix back into the full ruleset

Why:

- Prevents multiple errors from masking each other
- Separates chain-definition errors from rule-body errors

## 4. Check Chain Definition Before Rule Body

Many "rule" failures are actually chain-definition failures.

Use this fixed review order:

1. `family`
2. chain `type`
3. `hook`
4. `device` (especially `netdev` and `inet` + `ingress`)
5. `priority`
6. statement legality
7. payload/protocol context

## 5. Runtime Triage (Rules Load but Behavior Is Wrong)

First, confirm what is actually loaded:

```bash
nft -a list ruleset
```

Then check:

- whether another firewall tool is also active (`iptables`, distro wrappers, etc.)
- whether the expected packet path actually reaches the chain/hook you edited

Optional monitoring:

```bash
nft monitor
```

Note:

- Trace/monitor workflows vary by kernel and environment. If behavior still looks wrong, gather environment details before changing rule logic.

## 6. Error Buckets (Agent Output Template)

### A. Parser Errors

Symptoms:

- keyword/token/semicolon/braces problems

Agent response style:

- Provide a minimal corrected snippet
- Avoid rewriting unrelated rules

### B. Userspace Semantic Errors (`eval`)

Symptoms:

- unsupported hook for family
- missing or misplaced `device`
- conflicting protocol context
- `table inet` NAT address missing `ip`/`ip6`

Agent response style:

- Call this out as a semantic constraint (not syntax)
- Cite `constraints-matrix.md` section

### C. Kernel / Environment Errors

Symptoms:

- `nft -c` passes, but apply/load fails
- behavior differs across hosts

Agent response style:

- Mark as environment/version-dependent
- Ask for:
  - `nft --version`
  - `uname -r`
  - minimal reproducer

## 7. Conservative Generation Strategy (Reduce Hallucinations)

- If unsure about hook/action legality, generate:
  - chain declaration skeleton first
  - then rule bodies
  - and explicitly require `nft -c` validation
- In `table inet`, prefer two rules (IPv4 + IPv6) over a forced merged rule
- Do not claim hook support from memory when the matrix is available
