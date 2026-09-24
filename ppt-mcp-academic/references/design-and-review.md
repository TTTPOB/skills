# Design and Review

Applies across projects, content types, and templates. What follows is practice, not a fixed layout; read this task's audience, language, material, style, and color mapping first.

The final section, "Acceptance and Rework Mapping," turns common rework comments into a checklist you can verify item by item.

## A. Decide what to say first

Introduce the concepts, terms, or metrics that later sections reuse, matched to what the audience already knows. Do not assume listeners remember a definition from a previous project, and do not mechanically open every deck with experiment readings or a model recap.

For each slide, settle these before creating objects:

| Item | Question to answer |
|---|---|
| Slide point | What should the audience remember after leaving this slide? |
| Evidence or material | Which existing figure, table, equation, example, or source supports it? |
| Form of expression | Text, table, data figure, process, structure diagram, or comparison — which is easiest to understand? |
| Necessary limits | Which units, ranges, conditions, or evidence boundaries would be misread if left unsaid? |
| Speaker notes | Which details belong to the speaker rather than crowding the slide? |

When the title already states the conclusion in full, do not routinely add a synonymous "key takeaway" bar. When a title, subtitle, and caption all exist, each should do its own job.

Check the evidence and the applicable scope of the current content. For data, verify units, denominators, sample sizes, time windows, or grouping definitions; for processes and models, verify the arrows, stages, and inputs and outputs. Do not present correlation as causation, and do not conflate illustrative values, external results, and measured results. Put limits that affect the main conclusion on the slide and longer details in the notes.

## B. Diagrams show relationships, not decoration

| What you need to express | Visual language you can use | Avoid |
|---|---|---|
| Stages or process | Nodes and arrows with clear meaning | Splitting a paragraph into rows of unrelated boxes |
| System composition and hierarchy | Containment, partitioning, interfaces | Giving every object the same border so relationships cannot be told apart |
| Input, processing, output | Input icons, processing modules with embedded text, results | Drawing only complex icons without saying what they represent |
| Branching, merging, dependency | Forks, merge markers, or necessary operators | Using the same unexplained arrow for every relationship |
| Comparison, category, or state | Aligned layout, color coding, labels, or line styles | Making the audience guess from color alone |
| Algorithm or model (only when applicable) | Representation, branches, parameter sharing, and other necessary structure | Adding unverified structure or dimensions just to look like a model diagram |
| Learning pipeline (only when applicable) | Distinguish the training supervision path from the actual inference path | Making training information look like a required input at inference time |

Do not delete a diagram that carries explanatory value for the sake of brevity; do not wrap every word in a box for the sake of "a rich figure" either.

### Reuse the visual language, not the content logic

When the user approves a drawing approach, you can reuse its modules, arrows, labels, and use of whitespace. After changing slides or projects, re-verify the objects, inputs and outputs, relationships, conditions, and data sources; the same style does not mean the same logic.

Do not force reuse of an old model, entity count, symbols, prediction target, process stages, or page density.

## C. Color coding: define the meaning first, then verify across slides

### Build this deck's mapping

Keep a short mapping in the task notes; a configuration slide is not required:

| Field | What to pin down |
|---|---|
| What is encoded | Does color represent an entity, a role, a category, a state, or a value? |
| Color source | Explicitly specified for this task, from the current template, or from a confirmed source-figure convention? |
| Scope | Which slides, shapes, text, legends, or data figures should use it? |
| Supporting cues | How do names, legends, line styles, or symbols help distinguish categories? |
| Independent encodings | Which external figures use a different scheme with its own clear meaning? |

Apply color only when it helps understanding; do not color all text, and do not invent a second semantic scheme for decoration.

### Consistency checks

The same meaning keeps the same color across the deck; reordering categories, copying a template, or moving to another slide should not change a color. Within one coding scheme, avoid one color carrying mutually conflicting meanings.

Shape fills, their connectors, role cues in text, legends, and editable charts should line up. When several encoding dimensions are needed, define their scopes clearly — for example, use color for one dimension and line style or labels for another; do not merge them into one vague legend.

For continuous-value gradients, also check the direction and what the values mean. For several figures meant to be compared directly, keep the color scale comparable where possible; label differing ranges clearly, and do not imply that the same color means the same value.

### An existing data figure conflicts with the new palette

Read the original legend first; do not guess meaning from color alone. If the original figure and this deck encode the same object and the source figure can be safely modified, unify the mapping and re-check. When it cannot be reliably modified, keep the original figure and explain it clearly; do not recolor peripheral labels to the opposite meaning, and do not cover the legend with a color block.

If the original figure already encodes another dimension, keep its independent meaning and mark the boundary clearly; this is not a license to recolor the same object arbitrarily. At handoff, state any unresolved conflict, and do not report a "partial recolor" as "the whole deck is unified."

## D. Redundancy review: content layer

| Common problem | Fix |
|---|---|
| Title, takeaway bar, box text, and footer repeat the same conclusion | The title carries the point; other places provide evidence, relationships, or necessary limits |
| The process is fully drawn but transcribed step by step beside it | Delete the step-by-step repetition and keep only what the diagram cannot express |
| A symbol is defined next to it and a full copy is repeated at the bottom | Prefer the nearby definition; a centralized legend covers only shared or missing definitions |
| The same number appears in the figure, a large card, and a summary box | Keep it where comparison or reference is easiest and delete the other copies |
| Chinese and English appear in pairs but the second language adds no information | Follow the deck's language; introduce a necessary term bilingually once |

**Do not treat a necessary reminder as redundancy.** Concepts reintroduced across slides, units, conditions, sample sizes, and important limits may have to stay. Judge by comprehension cost, not by a mechanical word or repetition limit.

## E. Redundancy review: object layer

| Not recommended | Recommended | Reasonable exceptions or boundaries |
|---|---|---|
| Base rectangle + ordinary text textbox + duplicate border | One native shape with the text inside it | Content that genuinely needs independent positioning |
| A table faked from textboxes and horizontal lines | A native table | Genuinely non-tabular spatial relationships |
| A new color block covering an old mistake | Update or delete the original object | Do not treat covering as a routine fix |
| Every label in a card, cards inside cards | Express structure with alignment and whitespace | A large frame genuinely denoting a subsystem or stage |
| Re-running the whole batch after an error, leaving overlapping elements | Read the current state, then update or fill in | A confirmed replacement of one well-defined module |
| Screenshotting a whole slide to reduce object count | Keep native text, equations, tables, and grouping | Content that was already a photo, data figure, or external image |

A standalone native equation is not an extra layer. When items must move together, group the equation, any necessary base frame, and the caption; do not fall back to raw underscore text just to save an object.

To fix an existing redundant module: read the old text, style, and object identity → write the body text into the target shape → set size, margins, and alignment → confirm it is complete → delete the extra textbox or border → update the grouping → re-check.

Do not delete every empty shape in bulk: it may be a base frame, a connector, or an equation container. Judge by actual purpose and by repetition relationships.

## F. Grouping, alignment, and editability

### Group by how the user will move things

Group the nodes and line segments inside an icon first; then group the captions that must move together into a module. When a whole process must move, you may wrap another group around it, but do not indiscriminately stuff titles, page numbers, and whole-slide content into one group.

Whether a special object can take part in a group depends on what the current PowerPoint actually supports; do not convert figures to images for grouping, and do not retry a failed operation over and over.

### Centering a caption needs two checks

| Check | What it means |
|---|---|
| Centered inside the box | Paragraph alignment is center; also verify the internal margins, indentation, and line breaks |
| Box centered against the body | The caption box's center matches the horizontal center of the body it belongs to |

Use the body's visual boundary as the reference and do not count a distant connector, another caption, or an already offset label toward the center. Determine the body boundary, place the label, then group, and afterwards re-read the group's contents or look at a preview.

```text
body_center_x = body_left + body_width / 2
label_left = body_center_x - label_width / 2
```

Centering requires two conditions at once: the paragraph is centered, and the box's center matches the body's center.

## G. Fonts, sizes, and space

A font specified for this task or an already-confirmed template wins; when nothing else is required, prefer Source Han Sans SC for body text and keep a suitable math font for math objects. Font settings must cover Chinese and English, existing shapes, group members, and table cells.

Keep a readable size hierarchy and adjust it to the slide size, the display device, the viewing distance, and the preview. By default, avoid making numbers especially large purely for decoration; emphasis serves understanding, not filling the slide.

When it does not fit, delete redundancy, shorten the wording, adjust the area, or split the slide first; do not shrink a whole slide's text into unreadable small type.

Text already inside an image does not change with the deck's font settings. To unify it, modify the source image; until then you cannot claim the image's fonts are unified. Do not break math objects by replacing the deck's fonts wholesale.

## H. Images and overlap

Determine the available image area first, then scale by the original aspect ratio. After inserting, moving, or resizing, re-verify the boundaries and the ratio.

Focus on legends and axes, title line breaks, captions below, the dimensions of professionally typeset equations, and slide margins. Two objects intersecting only means you should check: text inside a container and an equation on a background frame are intentional containment; unrelated content covering each other is the error.

Combine object relationships with geometric checks; do not mechanically delete every intersecting object, and do not hide an old layout problem under a new overlay.

## I. Acceptance and rework mapping

| Check | How to confirm |
|---|---|
| Content meaning | Check back against this task's material: terms, directions, conditions, units, and evidence scope |
| Cross-slide consistency | The same meaning keeps the same color, term, symbol, and legend; independent encodings are explicit |
| Structure | Inspect objects and subgroups; confirm applicable native tables, native equations, real Groups, and no leftovers from a failed retry |
| Fonts and overflow | Verify Latin/Far East on body text and in table cells, measuring text when needed; read back the fields and check the display, not just `success` |
| Geometry and layout | Alignment matches intent; captions are centered correctly; image ratios and margins are reasonable |
| Content and object economy | Every piece of text and every shape has a distinct purpose; no repetition or layering that adds no information; extra base frames, same-named textboxes, and duplicate borders are cleaned up |
| Expression | Plain and simple, yet diagrams explain; the slide is not bare text boxes; jargon and repeated definitions are compressed |
| Terms and symbols | Short definitions nearby as the audience needs them; no critical undefined term and no fully repeated definition in several places |
| Emphasis and numbers | Numbers are readable and comparable; no repeated number cards or purely decorative giant numbers |
| Images and overlap | Plan the image area first and verify boundaries after inserting or modifying; axes, legends, titles, captions, and other content are not wrongly covered |
| Grouping and centering | Real groups exist with complete members and sensible drag behavior; a centered design checks both paragraph alignment and the body's geometric center |
| Focus | No pointless slide switching; address objects by name instead of selecting them, and batch operations that must steal focus; re-read state after the user edits manually |
| Visual | Preview newly built, heavily revised, and previously problematic slides within what is allowed, then re-check after fixing. Correct fields do not mean correct visuals; do not skip the preview |

### Rework comments and general rules

While working through the checklist above, use these correction intents to decide the fix; the table above remains the source of truth for confirmation.

| Correction intent | General rule |
|---|---|
| Simple and plain, but diagrams must explain | Do not pile on decoration, and do not turn every relationship you could draw into text |
| A concept or symbol needs a recap | Give a short definition nearby as the audience needs it, not a mechanical rewrite every time |
| Use color to distinguish content | Define this task's color-to-meaning mapping and apply it consistently across the deck |
| The original figure already uses a different color meaning | Check the encoding dimension first; do not break the original figure for surface consistency |
| The font looks like it did not really change | Set body text to this task's font and check Latin/Far East |
| A table should not be faked with textboxes | Use a native table for real row-and-column data |
| The slide is only dry text boxes | Draw a process, structure, or relationship from the content instead of wrapping sentences in boxes |
| A number does not need to be especially large | Avoid purely decorative giant numbers; make emphasis serve this task's purpose |
| An approved drawing approach needs reuse | Reuse the style, not the old content logic |
| Small shapes need real grouping | Group according to what must move together, rather than merely placing them near each other |
| An equation must not be underscore input | Use a native math object to do the typesetting needed |
| A shape can hold text directly | Prefer one native shape to carry text in an ordinary module |
| A caption is still not centered after grouping | A centered design checks both paragraph alignment and the body's geometric center |
| An operation steals the user's window focus | Address objects by name rather than selecting them, and batch operations that must steal focus |
| The task was reported done but something was missed | Check the final object state; do not count plans or tool batches as completion |
| Neither text nor shapes should be redundant | Check information repetition and extra object layers separately |

### A tool returning success does not mean it worked

| Return or symptom | Handling principle |
|---|---|
| A font replacement returns success but some text still shows the old font | `success` is not proof that all text actually took effect; check object by object |
| The font list is confused with what is installed on the system | Separate the deck's font references from the runtime's font availability, and make no unsupported promise about substitution |
| Inserting an equation returns success but no object was added | Compare object identities and selection state before and after; do not overwrite the old equation |
| Grouping completes but a caption is still offset | Grouping and alignment are separate acceptance items |
| A remote endpoint can read a temporary image URL | Verify what the receiving end can access; do not treat the address as a cross-task constant |

For operation details such as tool names, return structures, window behavior, and equation input, see [MCP Recipes](mcp-recipes.md) and re-check the current schema at execution time.
