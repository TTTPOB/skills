---
name: lead-agent-ownership
description: Coordinate delegated research or implementation without duplicate work; retain lead-agent ownership of review, integration, and final delivery.
user-invocable: true
---

# Subagent Delegation and Lead-Agent Ownership

Coordinate task decomposition, shared interfaces, dependencies, and decisions affecting the overall objective. Select subagents and arrange parallel or sequential work. Retain responsibility for acceptance review, integration, final delivery, and cleanup within the authorized scope.

## Delegate an actionable task

Write each assignment for the subagent receiving it. Include only information needed to execute, coordinate, or deliver that task:

- Objective and expected outcome.
- Owned files or modules, interfaces to preserve, and relevant dependencies.
- Implementation decisions the subagent can make independently.
- Specific changes that require discussion, such as expanding scope or changing an agreed interface or behavior.
- Deliverables and acceptance evidence.

Translate relevant user preferences into concrete task requirements. Keep model and reasoning-effort selection in the delegation tool arguments. Keep agent counts, parallelization strategy, and fallback routing in lead-agent coordination; tell each subagent only the collaboration boundaries that affect its work. If further delegation needs a restriction, state that permission directly.

Pass applicable skill guidance as task requirements when needed. Omit skill-invocation history and declarations of the lead agent's authority. Review each instruction: **Does this change how the recipient executes, coordinates, or delivers the task?** Delete instructions that add no necessary information.

Let the subagent choose implementation details within the agreed objective and interfaces. Assign testing, building, and committing permissions according to the actual workspace and collaboration arrangement. Distinguish final acceptance responsibility from who performs those operations, and identify concrete shared resources that require coordination. Ask for evidence and options when a limitation prevents meeting acceptance criteria.

## Coordinate ongoing work

After delegation, advance independent, non-conflicting work without repeating the subagent's task. Communicate interface changes and blockers to affected participants. When no independent work remains, wait for completion notifications rather than repeatedly polling or inventing busywork.

## Review and deliver

Review artifacts and supporting evidence against the objective and constraints. Check for unnecessary complexity, omissions, and conflicts. Verify specific doubts and integration risks instead of mechanically repeating the implementation or every check. Evaluate proposed deletions against current consumers and behavior before approving them.

Fix small issues directly. For flawed core designs, substantial deviations, or extensive rework, explain the concrete problem and return the task to the subagent.

Consolidate accepted work and perform necessary integration validation. Report completed outcomes, evidence, remaining limitations, and actual activation status where relevant. Treat completion claims as input to review, and conclude delivery and cleanup within the authorized scope.
