---
name: proportionate-engineering
description: Evaluate guards, validation, exception handling, abstractions, and tests through mental ablation; keep engineering proportional to realistic risks.
user-invocable: true
---

# Mental Ablation and Proportionate Engineering

**Prioritize code quality over minimal changes.** Optimize for correctness, simplicity, clarity, elegance, maintainability, and human readability—not the smallest diff. Refactor or replace existing code when doing so produces a cleaner, more coherent solution. Do not preserve awkward structures, redundant code, or unnecessary compatibility layers merely to reduce the size of the change.

**Judge simplicity by the resulting design, not by the patch size.** Choose the simplest design that serves the actual requirements, and apply mental ablation to both existing and proposed code: what useful behavior would be lost if this code or abstraction were removed? Remove what adds no concrete value.

Choose engineering complexity according to the actual operating environment and the cost of failure. Before adding a guard, validation, exception handler, lock, abstraction, or test, perform a mental ablation:

1. What specific failure would occur without it? Is its trigger realistically possible in this environment?
2. Do existing mechanisms already cover that failure? What additional protection or evidence does it provide?
3. Is there a simpler, more direct solution?

If you cannot identify a concrete benefit, do not add the measure. Apply the same standard when reviewing existing measures.

For personal, single-user, single-machine projects, do not default to bank-grade hardening. Avoid repeated hash or SHA verification, resource fingerprinting, repeated manifest consistency checks, and defensive systems built around hypothetical same-machine tampering or merely theoretical races. Introduce such mechanisms only when actual requirements justify them.

Exception handling must serve a clear purpose, such as recovery, resource cleanup, or adding useful error context. Avoid pointless wrapping, swallowed errors, and silent degradation. Surface unrecoverable failures promptly and propagate them.

Validate specific behavior changes and realistic risks, preferably with minimal, direct examples or targeted tests. Avoid redundant verification, coverage for its own sake, expanding test matrices, and unrelated testing frameworks.

Retain measures justified by real failures. Fix the concrete problem without wrapping it in an additional general-purpose defense system.

## Examples

### Simplify the implementation while preserving useful behavior

An old module contains obsolete animations and a system-back action that users still need.

- Avoid deleting the whole module because it is old, or keeping the whole module because one behavior remains useful.
- Remove the obsolete animations and replace the remaining machinery with a direct implementation of system back.

### Delete compatibility with no current requirement

A compatibility branch serves only a version the project no longer supports.

- Avoid retaining it and adding tests because it might be useful someday.
- Delete the branch and its dedicated tests. Investigate further only if there is a concrete doubt about a current consumer.

### Validate behavior without adding low-value tests

An effect is moved into its own module. Existing tests already exercise the relevant behavior.

- Avoid adding a test that only checks the registration label without executing the effect.
- Reuse the existing behavior tests. Add a focused check only if the move introduces a realistic regression they do not cover.
