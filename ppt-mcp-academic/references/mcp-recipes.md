# MCP 操作配方

**适用范围：** 以下工具名、字段与返回结构来自已有会话的接口快照，不是当前服务的在线验证。调用前发现当前工具并读取所需 schema。

## 1. 寻址、单位与工具发现

某些宿主通过 `search_tools` → `describe_tools` 发现工具，再直接调用 `mcp__ppt__ppt_*`，或在 `run_code` 中调用 `tools.mcp__ppt__ppt_*({params: {...}})`。宿主不同就使用实际提供的机制，不照抄不存在的函数。

| 用途 | 此接口快照中的工具 |
|---|---|
| 确认文稿与页面 | `ppt_get_presentation_info`、`ppt_list_slides`、`ppt_get_all_text` |
| 定位对象 | `ppt_list_shapes`、`ppt_get_shape_info`、`ppt_get_group_items` |
| 读文字和排版尺寸 | `ppt_get_text`，必要时 `measure: true` |
| 创建与修改 | `ppt_add_shape`、`ppt_add_textbox`、`ppt_set_text`、`ppt_update_shape` |
| 文字、段落、边距 | `ppt_format_text`、`ppt_format_text_range`、`ppt_set_paragraph_format`、`ppt_set_textframe` |
| 原生表格 | `ppt_add_table`、`ppt_set_table_data`、`ppt_set_table_cell`、`ppt_set_table_layout` |
| 原生公式操作 | `ppt_execute_mso`、`ppt_select_shapes`；可复用 `ppt_copy_shape_to_slide` |
| 分组 | `ppt_group_shapes`、`ppt_get_group_items` |
| 图片 | `ppt_add_picture_from_url`、`ppt_lock_aspect_ratio`；谨慎使用 `ppt_crop_picture` |
| 检查 | `ppt_check_typography`、`ppt_get_slide_preview` |

此快照的页面、表格行列和对象索引从 **1** 开始；位置与尺寸单位为 **pt**，72 pt = 1 inch。当前服务仍需核对，页面尺寸从目标文稿读取。

优先按对象名寻址，新增、删除或分组后索引可能变化。组内对象使用实际返回的完整路径。不把示例对象名、自动生成的名称或先前页码当作跨任务常量。

此快照的 `like_slide_index` 继承设计和布局，**不复制内容**。新增或移动页后更新页码映射。`ppt_set_slide_notes` 会替换原备注，因此先读已有内容再合并，不把补充来源变成删除讲者备注。

## 2. 批次、返回值与本次参数

一批完成一个确定模块，相关写操作顺序 `await`；只读的独立查询才考虑并发。不要让多个代理同时写同一个 PowerPoint 窗口。

以下帮助函数适用于记录中的 JSON 返回结构，不适用于图片预览。后文示例共用它；宿主或返回格式不同，应根据当前 schema 调整。

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

**执行前绑定本次参数。** 示例中的 `slideIndex`、`shapeName`、`memberNames`、`moduleName`、`sourceSlideIndex`、`sourceEquationName` 等来自当前文稿；`fontLatin`、`fontEastAsian`、字号、颜色、边界、标签和数据来自本次任务设置。它们不是自动存在的宿主变量，也不是工具字段名；不要原样执行尚未赋值的片段。

几何边界须符合实际页尺寸；数组、对象身份、字体和颜色应先核对。字体未指定时可采用主文件的个人默认，不在所有示例中写死某个模板。

预览工具返回图片，应通过宿主支持的图像输出方式查看，不强行作为 JSON 解析。返回摘要以对象名、修改范围和异常为主，不输出几百条重复 success 或图像原始数据。

**重试规则：** 批次不是事务。报错前可能已有修改；先重读目标页与组，再继续缺失操作。相对位移 `dleft/dtop` 重复执行会继续移动，恢复时优先使用核对后的绝对位置。未定义变量、对象名失效或返回异常都不应触发整段创建脚本盲重跑。

## 3. 字体：设置和实际显示分开核对

`fontLatin` 与 `fontEastAsian` 根据本次指定字体或模板确定；没有另行要求时，普通文字可优先使用 `Source Han Sans SC`。数学对象单独处理，不强行用正文字体覆盖。

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

字段为 **`font_name_fareast`**；新建工具可能只提供 `font_name`，以当前 schema 的 Latin/Far East 说明为准。

字体替换后回读字段确认实际生效：检查范围包括相关分组子项和表格单元格，跳过数学对象。

使用 `ppt_set_default_fonts` 时，先明确是否要影响已有文字。此快照可设 `apply_to_existing: false`，先只设新文字默认值，再针对普通文字应用，避免影响公式。局部修复不应擅自改整份主题。

**`ppt_list_fonts` 在此快照中列的是文稿引用或嵌入字体，不是远端系统已安装字体清单。** 字段回读确认对象设置；预览或用户端显示帮助核对替代情况。字体缺失未确认时如实说明，不自行寻找并上传字体文件。

## 4. 普通文字直接写在形状里

下面的 `moduleBounds`、`moduleLabel`、`bodyFontSize`、`textColor`、`moduleFill`、`cornerRadiusPt` 都须从本次布局或样式取得，不照抄示例坐标或颜色。

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

示例展示一种居中的模块，不要求所有内容都使用圆角、居中或相同内边距。不要再创建同名文本框叠上去；确需独立公式或外置图注时再单独建对象。

`auto_size: "none"` 不保证文字放得下，仍需测量或预览。先调整表达和尺寸，不靠缩小到难读来掩盖溢出。

形状创建用 `align`（横向对齐）；段落设置用 `alignment`；文本框垂直对齐用 `vertical_anchor`。段落换行使用 `\n`，段内软换行使用 `\v`，仅在确有排版需要时使用。

## 5. 应用本稿颜色映射

按实体或含义查找本次已确认的颜色，不按页码、数组顺序或复制来源选色。颜色字段的格式和更新方式按当前工具 schema。

普通形状文字的局部配色优先使用 `ppt_format_text_range`。先读实际文本和该接口的范围规则，再计算范围；不要为一段彩色文字新建覆盖文本框。

改名、调序或复制模块后，重新核对填充、文字、连线和图例是否仍对应正确含义。已有图片不能通过形状字体或填充设置可靠改色；需要修改时回到源图，否则按设计文档说明独立编码或未解决冲突。

## 6. 原生公式：验证一枚，再复用

### 基本流程

1. 记录目标页对象 ID，确认窗口处于适合插入新公式的状态，而非仍在编辑上一枚公式。
2. 执行 `ppt_execute_mso({command_name: "EquationInsertNew"})`。
3. 再列对象，用前后 ID 差集确认新对象。新增数不符时先查选择状态和原对象。
4. 用 `ppt_set_text` 写本次的线性表达式，选择该对象，再执行 `EquationProfessional`。
5. 设置适用数学字体、字号、位置、边距与对齐。
6. 在允许范围内预览上下标、帽号、分式或积分，以及公式边界；记录已验证对象供复用。

历史执行中出现过插入返回 success、实际新增对象数为 0 的情况。成功状态不证明新建了独立公式，不能因此覆盖上一枚公式。

### 复用已验证的原生公式

`equationInput` 来自本次所需公式；`mathFont` 与 `equationFontSize` 来自当前数学对象或模板。记录曾使用 `Cambria Math`，但不据此限制其他合适数学字体。

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

随后还要设置尺寸、边距和对齐，并视觉核对。不能假定复制后新公式长度与原公式相同。

可用中性测试输入检查所需数学结构，例如 `x_i`、`x_(ij)` 或 `I=∫_a^b f(x) dx`。这些只是排版测试示例，**不是本次内容，也不保证在任意输入模式下都能正确排版**；不把测试公式残留在成品中。

成品应显示数学排版，而不是裸露的线性输入。

普通形状能写字不等于能替代公式。需要独立公式时，清除底框里的重复线性文字，将公式、必要底框和解释按需组合。

## 7. 原生表格

先确定真实行列数，再创建、批量写入数据、设置单元格字体与对齐。此快照的 `ppt_set_table_data` 会静默跳过越界数据；行列数与数据长度可能不一致时先核对，写完回读内容。

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

执行前检查 `tableData` 非空、每行等长，并符合接口要求的二维文本数组类型。`tableBounds` 和 `tableFontSize` 由本页确定；表头加粗和对齐是示例，不是强制模板。

数字采用适合本次比较的一致精度；同列单位可放表头，混合单位须明确标注。长字段调列宽，不用额外 textbox 假装合并单元格。

替换旧假表格时，先记录确切组成对象，确认新表完整后再删除旧对象。回读内容与尺寸并预览，检查最小行高或自动换行是否挤到其他区域。

## 8. 真正 Group，再核对对齐

此快照的分组工具不接收 `group_name`，而是返回 `group_name`，随后可用 `ppt_update_shape` 重命名。

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

`memberNames` 至少两个成员，来自本次真实读取或返回。确认成员完整且无重名、无包含自身的错误嵌套，再按用户会怎样移动来分组。

先对齐说明与主体，再分组，之后重查子项。工具批量调用不等于 PowerPoint Group。说明需居中时，同时查段落设置和文本框相对主体的中心；不是调用 Group 后就自然居中。

组内修复使用返回的完整路径，不能只枚举顶层就断言某符号丢失。

## 9. 图片路径由哪端解释

Agent 与 PowerPoint 可能在同一台机器，也可能不在。先确认插图参数由哪端解析；Agent 的本地路径不自动等于 PowerPoint 端可读路径。

优先使用当前工具真实支持且已获授权的传输方式。历史记录中可通过 PowerPoint 端可访问的临时 HTTP 地址，调用 `ppt_add_picture_from_url` 插入；这只是可选方法，不要求所有环境都启动临时服务。

- 优先采用已授权且可访问的共享位置、上传能力或 URL。无法访问时说明具体缺口，不声称未传输的本地文件已被远端读取。
- 确需临时 HTTP 时，只暴露必要文件，限制无关目录访问，遵循用户允许的网络范围；不擅自把未公开材料上传公共图床。
- 按实际图片区设置坐标和尺寸；此快照可用 `fit: true` 保持比例并居中，后续缩放仍要核对纵横比锁。
- 此快照的 URL 工具描述为下载后插入并清理临时文件；先核对当前行为和结果，再判断图片是否已嵌入、是否还依赖 URL。结束后关闭自己启动且不再需要的临时服务。

图例、坐标轴和颜色含义不能被外围标签遮住。配色有冲突时按设计文档核对语义，不直接覆盖原图颜色。

## 10. 检查、焦点与交接

先用 `ppt_check_typography({slide_index, fix: false})` 检查，再对具体文本调用 `ppt_get_text(measure: true)`。自动修复可能改变宽度或换行，不默认全篇 `fix: true`。

这些工具不代替看页面：存在 Group 不保证成员完整，公式文字正确不保证数学排版正确。

此快照中，`ppt_get_slide_preview` 会切到目标页，`ppt_select_shapes` 会将窗口带到前台，`ppt_copy_shape_to_slide` 使用剪贴板。集中处理需要焦点的操作；其他操作是否影响窗口仍取决于当前实现，不承诺绝不干扰。

修后复查。用户刚刚手动修改时，重新读取实时对象，不用旧缓存覆盖。预览、保存、导出与关闭按本次任务分别确认。
