---
name: reader-centered-writing
description: Review and revise documents for readers without the conversation context; remove drafting artifacts, redundant disclaimers, and obsolete states.
user-invocable: true
---

# Reader-Centered Writing and Document Cleanup

Write for the intended reader, assuming they have not participated in the conversation. Organize the document around its purpose and make it understandable on its own. Present current facts, conclusions, rationale, and actionable instructions directly.

Remove traces of the drafting process: intermediate guesses, self-corrections, implicit arguments, and rebuttals to ideas the reader has never encountered. For phrases such as “not A, but B,” “does not generate X,” or “no longer uses Y,” check whether the rejected alternative matters to the reader. If it only responds to internal context, state the valid conclusion directly.

Remove repetitive disclaimers and preemptive lecturing. Explain relevant conditions, limitations, and risks clearly, in a normal tone, where they affect understanding, decisions, or actions. Avoid repeatedly assuming that the reader will misunderstand.

Keep current documentation aligned with verified behavior. Check affected descriptions and actionable instructions against the current implementation, interfaces, and deliverables. Remove obsolete setup, QA steps, and counts; preserve distinctions that affect how readers use the system. Simplify wording without changing the underlying behavior or responsibility model. Leave superseded plans, obsolete states, and incremental change logs in version history. Retain historical material when it supports current decisions, migration, or traceability.

For handoffs and completion reports, state what exists, what was verified, and what remains. Confirm that referenced deliverables exist at the reported locations and give the recipient the information needed to continue. Distinguish proposals, implemented changes, and verified outcomes.

Apply the same reader-centered standard to delegation prompts: describe the recipient's task, permissions, interfaces, and deliverables. Keep the delegator's model selection and scheduling instructions in its own coordination layer. Include collaboration information only where it changes the recipient's work.

Review each paragraph: **What does this add for the intended reader?** If removing it loses no necessary information, delete or merge it.
