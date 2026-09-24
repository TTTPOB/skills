---
name: ppt-mcp-academic
description: Use the PowerPoint MCP (ppt_* / mcp__ppt__ppt_*) to create, organize, or revise presentations for research reports, technical walkthroughs, teaching, and project updates. Follow the content, template, and color coding of the current task, and check native editable objects, diagrams, fonts, equations, tables, grouping, alignment, image-text overlap, and redundant text and shapes.
---

# Building and Revising Slides with the PowerPoint MCP

The goal is to **be clear, be readable, and stay easy to revise**. This skill provides cross-project practice and user defaults; it does not presuppose any project's content, model, palette, or page structure.

## Read by current need

| When you need to | Read |
|---|---|
| Organize content, draw diagrams, define color coding, trim slides, review and handle rework | [Design and Review](references/design-and-review.md) |
| Call the MCP, handle fonts, equations, tables, grouping, and remote images | The relevant sections of [MCP Recipes](references/mcp-recipes.md) |

Do not preload every API or session history. If the task has no tables, equations, or models, do not add them just to satisfy a checklist.

## 1. Separate general rules, personal defaults, and this task's settings

**Priority: this task's explicit user requirements → the template and conventions already confirmed for this deck → user default preferences → general advice.** Content accuracy, operation authorization, and honest reporting of verification scope always hold. When the existing deck conflicts with itself, check first; do not keep an error just to preserve a style.

Read the existing material first and form a short task brief: **goal and audience, language, target file and scope, evidence sources, style and fonts, color-to-meaning mapping, operation permissions.** Keep it as an internal note; do not make the user re-enter what they already gave you.

## 2. Establish the file and the operation scope first

- Discover the current MCP tools and read their actual schemas; treat the current service as authoritative.
- Read the current presentation info, the slide list, and the target slides' text and objects. Confirm the target file for this task; do not assume the currently focused window is the target.
- When asked to revise an existing deck, keep what is still useful, including its layout, and do not quietly make a replacement. When asked to create a new deck, do it with the capabilities you actually found and do not be limited by "you can only edit the current file."
- Save, save-as, export, and close exactly as this task requires; without authorization, do not overwrite-save or close files. Preview does not authorize a delivery export.
- Preview by slide when the task allows it; when the user forbids preview or the tools cannot provide it, state plainly that visual review was not completed.
- Do not re-run large analyses, change project code, or upload unpublished material just to build slides. Prefer results already provided and checkable in this task.

## 3. Design and editing rules

| Item | Requirement |
|---|---|
| Expression and language | Follow the language of this task and the existing deck; short sentences, little jargon, keep necessary terms. Each slide has a clear point; do not mechanically reuse one layout. |
| Style | Plain and clear by default. Emphasis on numbers should serve understanding, not giant numbers, marketing cards, or meaningless decoration; explicit template requirements win. |
| Fonts | A font specified for this task or an already-confirmed template wins; when unspecified, prefer `Source Han Sans SC` for body text. Check Latin and Far East fonts, group members, and table cells; keep a suitable math font for equations. |
| Diagrams | Draw the process, structure, relationships, or inputs and outputs clearly; use visual expression that matches the content and do not force in experiments, models, or training networks. Do not split one paragraph into many boxes. |
| Tables and equations | Use a native table for real row-and-column data, and a native equation when structured math typesetting is needed. Do not fake a table with textboxes, or treat raw underscore input as a finished equation. |
| Symbols and terms | Give a short definition nearby on first use, or when a reminder is genuinely needed, in the language of the deck. Do not rewrite the definition on every occurrence. |
| Grouping | Small shapes that form one icon must be truly Grouped; modules, equations, and captions that must move together should be grouped sensibly. Visual proximity is not grouping. |
| Alignment | Check before and after grouping. For a caption that must be centered, check both paragraph centering inside the box and the box's centering against the body. |
| Images | Preserve aspect ratio and plan the image area first; do not cover axes, legends, captions, equations, or other content. |

### Color coding: this project defines the meaning, and the whole deck stays consistent

Use color when it helps distinguish **entities, roles, categories, states, or data series**. Establish this deck's "meaning → color" mapping first; the same meaning keeps the same color in text, shapes, connectors, legends, and editable charts across slides, and must not change because you moved to another slide or copied a template.

Within one coding scheme, avoid one color carrying conflicting meanings; keep names, legends, or line styles as supporting cues and do not rely on color alone.

An existing data figure may encode another dimension. Check the semantics first, then decide whether to carry it over, unify it from the source figure, or clearly mark it as an independent encoding; **do not corrupt the data's meaning for surface consistency, and do not report an unresolved conflict as unified.** See the color checks in the design reference.

### No redundant text or shapes — check both layers

**Content layer: say it once, do not repeat it in several places.** Titles, takeaway bars, in-figure labels, and footers should not paraphrase the same sentence. When the diagram already shows a process, do not transcribe it step by step beside it; keep necessary variable explanations, units, limits, and evidence sources.

**Object layer: one purpose, achieved with as few native objects as possible.** Put ordinary module text directly into a shape. Do not build "rectangle base + overlapping textbox + another border," and do not cover an old mistake with a new object. Standalone native equations, external captions, and text that genuinely needs independent positioning are reasonable exceptions; group and align them as needed.

Before adding any object, ask: **what new information, relationship, or necessary editing capability does it provide, and what is lost if it is removed?** If there is no clear purpose, do not add it; if redundancy already exists, delete or merge it. Do not compress a whole slide into an image just to have fewer objects.

## 4. Working order

1. **Read the current state, check the evidence and this task's conventions.** Map target slides to the material and verify terms, data meaning, fonts, and the color mapping. When old conclusions conflict with new material, verify before changing.
2. **Settle the content before arranging objects.** Define the slide's point, its evidence, the most suitable form of expression, and the necessary limits. Sort out complex relationships logically before stacking shapes.
3. **Validate one representative module first.** Check fonts, embedded text, color, and any applicable equations, tables, and grouping, then reuse the style. Reuse the drawing approach, not another project's logic or data.
4. **Execute in batches by slide or module.** Sequence dependent operations with `await`; do not run writes against the same PowerPoint in parallel. Record the object names actually returned and name them by meaning.
5. **Trim redundancy → lay out → group → re-check.** Prefer updating existing objects; after a batch error, re-read the state and fill in what is missing.
6. **Run a structural check and a visual check.** Check object types, group members, fonts, overflow, alignment, image boundaries, and duplicate content; verify color and terminology across slides. Re-check affected slides after fixing. Judge acceptance by the actual object state, not by a tool's success.
7. **Hand off briefly.** State what changed, what was not verified, what needs the user's confirmation, and the actual save/export state.

## 5. Shared window and delivery checks

Address objects by name for ordinary reads and writes, and do not switch slides or select objects for every step. Equations, copy, and preview may affect focus or the clipboard: batch the operations that need focus.

When the user reports an accidental delete, an undo, or a state rollback, re-enumerate that slide and the related groups, fix only the objects confirmed broken, and do not overwrite the user's other changes.

Before delivery, verify: **this task's settings are correct; semantic colors match across slides; there is no ineffective duplication of text and shapes; body text is embedded; the native tables/equations needed are correct; fonts actually took effect; group members are complete; alignment is correct; image ratios and boundaries are reasonable.**

Skip items that do not apply; mark what you could not do as unverified, and do not hide problems by piling on decoration, shrinking text until it is unreadable, or making the user redo everything.
