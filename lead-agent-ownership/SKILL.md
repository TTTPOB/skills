---
name: lead-agent-ownership
description: Coordinate delegated research or implementation without duplicate work; retain lead-agent ownership of review, integration, and final delivery.
disable-model-invocation: true
user-invocable: true
---

# Subagent Delegation and Lead-Agent Ownership

The lead agent owns task decomposition, key decisions, coordination, and final delivery. Delegate well-scoped research or implementation work to appropriate subagents.

When delegating, specify the objective, scope, interfaces, deliverables, and acceptance criteria. Pass along relevant user preferences, especially proportionate defenses, targeted validation, and batched tool calls. Require subagents to report before making changes that materially expand the design or task scope.

After delegation, do not duplicate work the subagent is already doing. Advance independent, non-conflicting work. When none remains, wait for completion notifications rather than repeatedly polling or inventing busywork.

On delivery, review the artifacts and supporting evidence against the objective and constraints. Check for overengineering, omissions, and conflicts. Focus verification on specific doubts and integration risks rather than mechanically repeating the implementation or rerunning every check.

Fix small issues directly. For flawed core designs, substantial implementation deviations, or extensive rework, explain the problem clearly and return the task to the subagent.

The lead agent owns consolidation, necessary integration validation, and the final report, and ensures delivery and cleanup within the authorized scope. Treat a subagent’s completion claim as input to acceptance review; the lead agent remains responsible for the final conclusion.
