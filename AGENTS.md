# Project Meta Instructions (Session-Specific)

This file records project-specific meta instructions provided in this session.
It intentionally excludes global `AGENTS.md` rules.

## Scope and Positioning

- The `nftables-rule-writing` skill is not only for error detection/linting.
- It must also cover:
  - quickstart guidance
  - reference/navigation material
  - practical usage patterns

## Language Requirements for the Skill Content

- The skill content itself should be written in English.


## Persistence / Deployment Reality Requirement

- Do not assume `/etc/nftables.conf` is the only persisted nftables source.
- Include guidance to inspect systemd units and drop-ins for nftables loading paths and `nft` invocations.
- Include a grep/ripgrep-based scan across common systemd unit directories to discover:
  - direct `nft` calls in `ExecStart` / `ExecReload` / `ExecStop`
  - references to `.nft` files
  - custom wrapper services that load rules

## Practical Additions Expected

- Include operational guidance (runtime inspection, apply/validate, monitoring, rollback).
- Include troubleshooting guidance for deployed systems.
- Include example rulesets/patterns, not only conceptual notes.

