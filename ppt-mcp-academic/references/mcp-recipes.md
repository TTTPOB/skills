# MCP Recipes

**Scope:** the tool names, fields, and return structures below come from interface snapshots in earlier sessions and are not an online verification of the current service. Discover the current tools and read the schemas you need before calling them.

## 1. Addressing, units, and tool discovery

Some hosts discover tools through `search_tools` → `describe_tools` and then call `mcp__ppt__ppt_*` directly, or call `tools.mcp__ppt__ppt_*({params: {...}})` inside `run_code`. Use whatever mechanism the current host actually provides; do not copy functions that do not exist.

| Purpose | Tools in this interface snapshot |
|---|---|
| Confirm the deck and slides | `ppt_get_presentation_info`, `ppt_list_slides`, `ppt_get_all_text` |
| Locate objects | `ppt_list_shapes`, `ppt_get_shape_info`, `ppt_get_group_items` |
| Read text and layout measurements | `ppt_get_text`, with `measure: true` when needed |
| Create and modify | `ppt_add_shape`, `ppt_add_textbox`, `ppt_set_text`, `ppt_update_shape` |
| Text, paragraphs, margins | `ppt_format_text`, `ppt_format_text_range`, `ppt_set_paragraph_format`, `ppt_set_textframe` |
| Native tables | `ppt_add_table`, `ppt_set_table_data`, `ppt_set_table_cell`, `ppt_set_table_layout` |
| Native equation operations | `ppt_execute_mso`, `ppt_select_shapes`; `ppt_copy_shape_to_slide` can be reused |
| Grouping | `ppt_group_shapes`, `ppt_get_group_items` |
| Images | `ppt_add_picture_from_url`, `ppt_lock_aspect_ratio`; use `ppt_crop_picture` with care |
| Checks | `ppt_check_typography`, `ppt_get_slide_preview` |

In this snapshot, slide, table row/column, and object indices start at **1**; positions and sizes are in **pt**, with 72 pt = 1 inch. Verify against the current service, and read the slide dimensions from the target deck.

Address objects by name where possible; indices can shift after adding, deleting, or grouping. For objects inside a group, use the full path actually returned.

In this snapshot, `like_slide_index` inherits the design and layout and **does not copy content**. Update the page mapping after adding or moving slides. `ppt_set_slide_notes` replaces the existing notes, so read what is there and merge rather than turning an addition into a deletion of the speaker's notes.

## 2. Batches, return values, and this task's parameters

One batch completes one well-defined module; sequence related writes with `await`, and consider concurrency only for independent read-only queries. Do not let several agents write to the same PowerPoint window at once.

The helper below fits the JSON return structure in the records and does not apply to image previews. The examples later in this file share it; if the host or return format differs, adapt it to the current schema.

```javascript
function unwrapPpt(response) {
  if (response?.isError) {
    throw new Error("MCP returned an error");
  }
  let value = response?.structuredContent?.result;
  if (value === undefined) {
    const part = response?.content?.find(
      item => item.type === "text" && typeof item.text === "string"
    );
    if (!part) throw new Error("No JSON result; inspect the tool response");
    value = part.text;
  }
  if (typeof value === "string") value = JSON.parse(value);
  if (!value || typeof value !== "object") {
    throw new Error("Unexpected PPT result format");
  }
  if (value.success === false || value.status === "error" || value.error) {
    throw new Error(JSON.stringify(value));
  }
  return value;
}
async function ppt(tool, params) {
  const name = `mcp__ppt__${tool}`;
  return unwrapPpt(await tools[name]({params}));
}
```

**Bind this task's parameters before executing.** Identifiers such as `slideIndex`, `shapeName`, `memberNames`, `moduleName`, `sourceSlideIndex`, and `sourceEquationName` in the examples come from the current deck; `fontLatin`, `fontEastAsian`, sizes, colors, bounds, labels, and data come from this task's settings. They are not host variables that exist automatically, and they are not tool field names; do not run a fragment whose values you have not assigned.

Geometric bounds must fit the actual slide dimensions; verify arrays, object identity, fonts, and colors first. When no font is specified, take the deck's personal default rather than hardcoding one template across every example.

Preview tools return images and should be viewed through whatever image output the host supports; do not force-parse them as JSON. Keep summaries to object names, the scope of changes, and anomalies rather than emitting hundreds of repeated `success` entries or raw image data.

**Retry rules:** a batch is not a transaction. Changes may already exist before an error; re-read the target slide and group first, then continue the missing operations. Repeated relative offsets `dleft`/`dtop` keep moving the object, so restore from verified absolute positions. Undefined variables, invalid object names, or abnormal returns should not trigger a blind re-run of the whole creation script.

## 3. Fonts: set them and verify what actually displays

`fontLatin` and `fontEastAsian` follow the font or template specified for this task; when nothing else is required, ordinary text may prefer `Source Han Sans SC`. Handle math objects separately and do not force the body font over them.

```javascript
await ppt("ppt_format_text", {
  slide_index: slideIndex,
  shape_name_or_index: shapeName,
  font_name: fontLatin,
  font_name_fareast: fontEastAsian
});
const checked = await ppt("ppt_get_text", {
  slide_index: slideIndex,
  shape_name_or_index: shapeName,
  measure: true
});
console.log(checked);
```

The field is **`font_name_fareast`**; a newer tool may only offer `font_name`, so follow the Latin/Far East description in the current schema.

After replacing fonts, read the fields back to confirm they actually took effect: check the relevant group members and table cells and skip math objects.

When using `ppt_set_default_fonts`, decide first whether existing text should be affected. This snapshot supports `apply_to_existing: false`, which sets defaults for new text only; then apply the font to ordinary text, avoiding the equations. A local fix should not change the whole theme on its own.

**In this snapshot, `ppt_list_fonts` lists the deck's referenced or embedded fonts, not the fonts installed on the remote system.** Field read-back confirms the object's settings; a preview or the user's display helps verify substitution. When a font is missing and unconfirmed, say so honestly and do not go find and upload a font file on your own.

## 4. Put ordinary text directly in the shape

The values `moduleBounds`, `moduleLabel`, `bodyFontSize`, `textColor`, `moduleFill`, and `cornerRadiusPt` below must all come from this task's layout or style; do not copy example coordinates or colors.

```javascript
const box = await ppt("ppt_add_shape", {
  slide_index: slideIndex,
  shape_type: "rounded_rectangle",
  left: moduleBounds.left,
  top: moduleBounds.top,
  width: moduleBounds.width,
  height: moduleBounds.height,
  text: moduleLabel,
  font_name: fontLatin,
  font_size: bodyFontSize,
  font_color: textColor,
  align: "center",
  fill_color: moduleFill,
  line_visible: false,
  corner_radius_pt: cornerRadiusPt
});
await ppt("ppt_format_text", {
  slide_index: slideIndex,
  shape_name_or_index: box.shape_name,
  font_name: fontLatin,
  font_name_fareast: fontEastAsian
});
await ppt("ppt_set_textframe", {
  slide_index: slideIndex,
  shape_name_or_index: box.shape_name,
  vertical_anchor: "middle",
  auto_size: "none",
  margin_left: 6, margin_right: 6,
  margin_top: 4, margin_bottom: 4
});
```

The example shows one kind of centered module; it does not require rounded corners, centering, or the same margins everywhere. Do not create another textbox with the same name on top of it; when a standalone equation or external caption is genuinely needed, create it as its own object.

`auto_size: "none"` does not guarantee the text fits; measurement or a preview is still required. Adjust the wording and the dimensions first rather than hiding overflow by shrinking text until it is unreadable.

Shape creation uses `align` (horizontal alignment); paragraph settings use `alignment`; a text frame's vertical alignment uses `vertical_anchor`. Use `\n` for a paragraph break and `\v` for a soft line break inside a paragraph, and only when the layout genuinely needs it.

## 5. Apply this deck's color mapping

Look up the color already confirmed for this entity or meaning; do not pick colors by page number, array order, or copy source. The format of color fields and how to update them follow the current tool schema.

For coloring part of the text in an ordinary shape, prefer `ppt_format_text_range`. Read the actual text and that interface's range rules first, then compute the range; do not create an overlay textbox for one span of colored text.

After renaming, reordering, or copying modules, re-verify that fills, text, connectors, and legends still match the right meaning. An existing image cannot be reliably recolored through shape font or fill settings; when it must change, go back to the source image, or otherwise mark an independent encoding or unresolved conflict as described in the design reference.

## 6. Native equations: validate one, then reuse

### Basic flow

1. Record the target slide's object IDs and confirm the window is in a state fit for inserting a new equation, rather than still editing the previous one.
2. Run `ppt_execute_mso({command_name: "EquationInsertNew"})`.
3. List objects again and confirm the new object from the difference in IDs before and after. If the count does not match, check the selection state and the original objects first.
4. Use `ppt_set_text` to write this task's linear expression, select that object, then run `EquationProfessional`.
5. Set a suitable math font, size, position, margins, and alignment.
6. Preview subscripts, superscripts, hats, fractions, or integrals, plus the equation's bounds, within what is allowed; record the validated object for reuse.

Earlier runs included cases where insertion returned `success` but the actual number of new objects was 0. A success status is not proof that a standalone equation was created, and you must not overwrite the previous equation because of it.

### Reusing a validated native equation

`equationInput` comes from the equation this task needs; `mathFont` and `equationFontSize` come from the current math object or template. `Cambria Math` has been used, but that does not restrict other suitable math fonts.

```javascript
const copied = await ppt("ppt_copy_shape_to_slide", {
  src_slide_index: sourceSlideIndex,
  shape_name_or_index: sourceEquationName,
  dst_slide_index: slideIndex
});
const equationName = copied.new_shape_name;
await ppt("ppt_set_text", {
  slide_index: slideIndex,
  shape_name_or_index: equationName,
  text: equationInput
});
await ppt("ppt_select_shapes", {
  slide_index: slideIndex,
  shape_names: [equationName]
});
await ppt("ppt_execute_mso", {command_name: "EquationProfessional"});
await ppt("ppt_format_text", {
  slide_index: slideIndex,
  shape_name_or_index: equationName,
  font_name: mathFont,
  font_size: equationFontSize
});
```

Afterwards, still set the size, margins, and alignment, and verify visually. Do not assume a copied equation is the same length as the original.

You can check the math structure you need with neutral test input such as `x_i`, `x_(ij)`, or `I=∫_a^b f(x) dx`. These are typesetting test examples only, **not this task's content, and they are not guaranteed to typeset correctly in every input mode**; do not leave a test equation in the finished deck.

The finished slide should show typeset math, not raw linear input.

An ordinary shape being able to hold text does not mean it can replace an equation. When a standalone equation is needed, clear the duplicated linear text in the base frame and group the equation, any necessary base frame, and the explanation as needed.

## 7. Native tables

Determine the real row and column counts first, then create the table, write the data in a batch, and set the cell fonts and alignment. In this snapshot, `ppt_set_table_data` silently skips out-of-range data; when the row/column counts and the data length may disagree, verify first and read the content back after writing.

```javascript
const table = await ppt("ppt_add_table", {
  slide_index: slideIndex,
  rows: tableData.length,
  cols: tableData[0].length,
  left: tableBounds.left,
  top: tableBounds.top,
  width: tableBounds.width,
  height: tableBounds.height
});
await ppt("ppt_set_table_data", {
  slide_index: slideIndex,
  shape_name_or_index: table.shape_name,
  data: tableData,
  bold_first_row: true
});
for (let r = 1; r <= tableData.length; r++) {
  for (let c = 1; c <= tableData[0].length; c++) {
    await ppt("ppt_set_table_cell", {
      slide_index: slideIndex,
      shape_name_or_index: table.shape_name,
      row: r, col: c,
      font_name: fontLatin,
      font_name_fareast: fontEastAsian,
      font_size: tableFontSize,
      alignment: c === 1 ? "left" : "center",
      vertical_alignment: "middle"
    });
  }
}
```

Before running, check that `tableData` is non-empty, that every row has the same length, and that it matches the interface's expected two-dimensional array of text. `tableBounds` and `tableFontSize` come from this slide; the bold header row and the alignment are examples, not a required template.

Use one consistent precision suited to this task's comparisons; put a shared unit in the header and label mixed units clearly. Widen columns for long fields instead of faking merged cells with an extra textbox.

When replacing an old fake table, record its exact component objects first, confirm the new table is complete, and then delete the old objects. Read the content and dimensions back and preview, checking whether a minimum row height or text wrapping crowds other areas.

## 8. Real Groups, then verify alignment

In this snapshot, the grouping tool does not accept `group_name`; it returns `group_name`, which you can then rename with `ppt_update_shape`.

```javascript
const grouped = await ppt("ppt_group_shapes", {
  slide_index: slideIndex,
  shape_names: memberNames
});
await ppt("ppt_update_shape", {
  slide_index: slideIndex,
  shape_name: grouped.group_name,
  name: moduleName
});
const inspected = await ppt("ppt_get_group_items", {
  slide_index: slideIndex,
  shape_name_or_index: moduleName
});
console.log(inspected);
```

`memberNames` needs at least two members, taken from real reads or returns in this task. Confirm the members are complete and free of duplicate names or wrong nesting that includes the group itself, then group according to how the user will move things.

Align the caption with the body before grouping, then re-check the members afterwards. A batch tool call is not a PowerPoint Group. When a caption must be centered, check both the paragraph settings and the textbox's center relative to the body; centering does not happen just because you called Group.

Repair inside a group with the full path that was returned; do not assert that a symbol is missing from a top-level enumeration alone.

## 9. Which end resolves the image path

The Agent and PowerPoint may or may not be on the same machine. Confirm which end resolves the image parameter first; the Agent's local path is not automatically a path the PowerPoint side can read.

Prefer a transfer method the current tools genuinely support and that is already authorized. Historical records show images inserted through a temporary HTTP address reachable from the PowerPoint side via `ppt_add_picture_from_url`; that is only one option and does not require every environment to start a temporary server.

- Prefer an already authorized and reachable shared location, upload capability, or URL. When it is unreachable, state the specific gap; do not claim that a local file you never transferred was read remotely.
- When a temporary HTTP server is genuinely needed, expose only the necessary files, restrict access to unrelated directories, and stay within the network range the user allows; do not upload unpublished material to a public image host on your own.
- Set coordinates and dimensions to the actual image area; this snapshot supports `fit: true` to preserve the ratio and center, and later resizing must still verify the aspect-ratio lock.
- This snapshot's URL tool is described as downloading, inserting, and cleaning up the temporary file; verify the current behavior and result first, then judge whether the image is embedded or still depends on the URL. Shut down any temporary service you started and no longer need.

Legends, axes, and color meanings must not be hidden by peripheral labels. When colors conflict, verify the semantics as described in the design reference rather than overwriting the original image's colors.

## 10. Checks, focus, and handoff

Start with `ppt_check_typography({slide_index, fix: false})`, then call `ppt_get_text(measure: true)` for specific text. Automatic fixes can change width or line breaks, so do not default to `fix: true` across the deck.

These tools do not replace looking at the slide: an existing Group does not guarantee complete members, and correct equation text does not guarantee correct math typesetting.

In this snapshot, `ppt_get_slide_preview` switches to the target slide, `ppt_select_shapes` brings the window to the foreground, and `ppt_copy_shape_to_slide` uses the clipboard. Batch the operations that need focus; whether other operations affect the window still depends on the current implementation, so do not promise that they never interfere.

Re-check after fixing. When the user has just edited manually, re-read the live objects rather than overwriting with a stale cache. Confirm preview, save, export, and close separately for this task.
