# PowerPoint MCP skill: cross-project edition

Build and revise decks for different projects with one approach: accurate content, native and editable, diagrams that explain, no redundant text or shapes, and consistent color coding throughout.

The original skill name `ppt-mcp-academic` is kept so it can replace an existing installation; the name does not restrict discipline, project, content type, or template. The entry description already covers research, technical, teaching, and project reporting.

## Scope

| Kept as general practice | Determined by the current task |
|---|---|
| No redundant text or shapes; body text embedded | Project names, entity names, page numbers, concrete content |
| One meaning keeps one color across the whole deck | Which object uses which color; whether a source figure has its own encoding |
| Native tables and equations, real grouping, correct alignment | Whether tables, equations, flowcharts, or models are needed |
| Fonts actually take effect; check both structure and visuals | This task's font, template, language, layout, and sizes |
| Safe retries, verifying remote paths, minimizing focus stealing | File location, runtime environment, transfer method, operation scope |

Source Han Sans SC and a plain style are overridable personal defaults, not hard constraints for every project. The current task's explicit requirements and a confirmed template come first.

The package ships no reference screenshots from any single project, and no fixed model, data, experimental setup, or entity palette.

## Install or update

Put the complete `ppt-mcp-academic/` folder into the skills directory your Agent is configured to use. The exact directory and refresh method follow that Agent's configuration.

When updating an older version, back up your own modifications first, then replace the same-named directory with the new version in full; do not overwrite only `SKILL.md`, and do not leave the old reference images or old reference files behind in the new directory. The top-level directory of this package is still `ppt-mcp-academic/`, so it will not install a duplicate skill under a different name.

```text
ppt-mcp-academic/
├── SKILL.md
├── README.md
└── references/
    ├── design-and-review.md
    └── mcp-recipes.md
```

## Files

| File | Purpose |
|---|---|
| [SKILL.md](SKILL.md) | Entry point, rule priority, working order, and delivery checks |
| [Design and Review](references/design-and-review.md) | Content organization, color mapping, trimming redundancy, grouping, alignment, layout checks, and rework mapping |
| [MCP Recipes](references/mcp-recipes.md) | Interface notes and parameterized examples, read on demand |

There is no need to read the whole package every time. When invoking the skill, say that you are using it and provide this task's material or target deck.
