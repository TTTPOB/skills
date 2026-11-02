---
name: academic-reveal-deck
description: 用 Quarto (.qmd) + reveal.js 制作学术汇报网页幻灯片：选型、文件结构、qmd 头部、MathJax 公式、示意图内公式、交互插件、自包含 HTML 导出与渲染检查。用户要做 reveal.js / Quarto / HTML 形式的组会、进度或学术汇报时使用；要交 pptx 时不用。
---

# 学术汇报：Quarto + reveal.js

本文件讲工具和流程。版式、配色、写作偏好在 [STYLE.md](STYLE.md)，开工前先读。
`assets/` 里是可直接复制进项目的起步文件。

## 1. 选型

| 场景 | 做法 |
|---|---|
| 文字、图、表为主 | qmd（默认） |
| 个别页要自由排版 | qmd 内嵌 HTML（第 5 节） |
| 整页是独立交互应用 | 单独生成 HTML，qmd 里放链接或 iframe |
| 必须交 pptx | 不用本 skill |

reveal.js 的原生能力（Auto-Animate、背景、`Reveal` API、插件）在 qmd 里都能用；只有整套汇报要做成前端应用时才值得手写 reveal.js。

## 2. 开工前确认

1. 听众和时长：决定背景、方法、结果各占多少页。
2. 交付方式：自己上台放，还是发给别人离线看（第 8 节）。
3. 已有素材：旧稿、原图文件、绘图脚本。先找原文件，再决定是否新画。
4. 项目约定：仓库若有 `AGENTS.md`、术语表、来源记录、输出目录规则，一律以项目为准。

## 3. 文件结构

```
<deck>/
  <main>.qmd          # 主稿；只读取已保存的图和数字，不做计算
  <variant>.qmd       # 可选：同素材的另一版本（删减版、背景版），不改主稿
  slides.scss         # 共享主题，起步见 assets/slides.scss
  title-slide.html    # 空封面 partial，见第 4 节
  math-raw.lua        # 公式过滤器，见第 6 节
  mathjax-chtml.html  # MathJax 配置
  pointer.html        # 可选：激光笔
  vendor/             # 本地化的第三方插件
```

- 图由独立脚本生成并保存，qmd 只引用；改图改脚本，不改 qmd。
- 渲染产物（`.html`、`*_files/`）不进版本库。
- 修改时更新原 qmd，不复制出 `v2`。

## 4. qmd 头部

```yaml
---
title: "<标题>"
format:
  revealjs:
    theme: [default, slides.scss]
    width: 1280
    height: 720
    margin: 0
    center: false
    slide-number: c/t
    transition: none
    hash: true
    navigation-mode: linear
    slide-level: 2
    template-partials: [title-slide.html]
    html-math-method: plain
    include-in-header: [mathjax-chtml.html]
filters: [math-raw.lua]
execute: { freeze: false, echo: false, warning: false }
---
```

- **封面**：Quarto 会按 `title` 自动生成封面，`title-slide: false` 无效。想自己排封面，就用只含注释的 `title-slide.html` 覆盖它，然后在正文第一页写封面。
- **主题**：用 `default` 加自己的 scss。部分内置主题（如 `simple`）会请求 Google Fonts，断网或内网会卡住加载。
- **`margin: 0`**：画布按 1:1 显示，不再缩到 0.94 倍，细线和小字更清楚。

## 5. 在 qmd 里内嵌 HTML

1. ` ```{=html} ` 原始块：内联 SVG、自定义结构。
2. `::: {.class}` 加 scss：两栏、网格、贴底脚注等布局。
3. `include-in-header`：注入 `<script>`、`<style>`。

**矢量图优先内联 SVG**，比 `<img src="x.svg">` 清晰，也能被页面 CSS 控制。同一页内联多个 SVG 时，给每个 SVG 的 `id`、`href="#…"`、`url(#…)` 加唯一前缀，否则渐变、裁剪路径会互相串用。

## 6. 公式

**页面公式：MathJax 3 CHTML，正常写 `$...$` / `$$...$$`。**

1. 复制 `assets/math-raw.lua` 和 `assets/mathjax-chtml.html`，按第 4 节头部引用。
2. 原因：Quarto revealjs 默认的 `html-math-method: mathjax` 走 reveal 的 MathJax 2 式插件（会给 URL 加 `config=TeX-AMS_HTML-full`）；改成 `plain` 后 Pandoc 又会把 `$...$` 转成 Unicode。过滤器把 TeX 原样输出成 `\(...\)` / `\[...\]`，交给页面自己加载的 MathJax 3。
3. `mathjax-chtml.html` 在排版完成后调用 `Reveal.layout()`，避免公式撑高页面后错位。

**示意图里的公式：先渲染成 SVG，再合进整张图。**

1. 用 MathJax 的 `tex2svg`（Node 端，`mathjax-full` 包）把每个公式渲染成独立 SVG。字形是路径，不依赖字体。
2. 换算尺寸：MathJax SVG 的 `viewBox` 以 1/1000 em 为单位，目标宽度 = `viewBox` 宽 × 字号(px) / 1000，高度同理。
3. 在绘图脚本里按锚点（居中、基线）放置：drawsvg 用 `draw.Raw(...)` 插入嵌套 `<svg x y width height viewBox>`；其他工具同理。
4. 多个公式 SVG 合并前，给内部 `id` 和引用加前缀（同第 5 节）。
5. 整张图导出为一个 SVG，再内联进 qmd。公式随图缩放，不会错位。

## 7. 交互

- **激光笔**：`reveal.js-pointer`。把 `pointer.js`、`pointer.css`、`LICENSE` 下载到 `vendor/`，按 `assets/pointer.html` 注册（`RevealPointer` 是工厂函数，要调用后再注册）。
- **大交互图（如 Plotly）**：用本地安装的库生成，JS 放本地。切页时重算尺寸：`Reveal.on("slidechanged", …)` 里调用库的 resize。页脚给一个独立大图链接。
- 交互图和激光笔同用时，给插件光标设高 `z-index`，并隐藏图表自己的光标，否则光标被图层盖住。

## 8. 交付

| 需求 | 做法 |
|---|---|
| 自己上台 | 直接打开渲染出的 HTML，相对路径即可；MathJax 走 CDN，需要联网 |
| 发给他人 | 单个自包含 HTML（见下） |
| 删减版、背景版 | 单独的 qmd，共享 scss 和素材 |

**自包含 HTML 的步骤：**

1. 正常渲染出 HTML。
2. 预渲染公式：无头浏览器打开页面，等 `MathJax.startup.promise` 完成，按顺序取出每个 `span.math` 里的 `mjx-container`，以及 MathJax 注入的 CHTML 样式表；样式表里的字体 URL 转成 `data:` URI。
3. 用脚本处理**渲染出的原始 HTML 文件**（不要保存浏览器里被 Reveal 改过的 DOM）：
   - 按顺序把 `span.math` 换成第 2 步的结果，删掉 MathJax 配置和加载脚本；
   - `<img>`、`<script src>`、`<link>`，以及 CSS 里的 `url()`、`@import`，本地文件一律内联或转 `data:` URI，已是 `data:`、`#` 开头的保持原样。
4. 断网检查：拦截所有外部请求后打开，核对页数、坏图数为 0、公式数与源稿一致。

Quarto 的 `embed-resources` / `self-contained-math` 不能解决这个问题：CHTML 字体仍在运行时联网加载（quarto-cli issue #9404）。

## 9. 渲染检查

写成一个脚本，一次跑完，只看输出，不逐页手动点浏览器：

1. Playwright 打开 HTML，等公式渲染完，循环 `Reveal.slide(i)`。
2. 每页检查：元素底边超出画布、`scrollHeight > clientHeight`、`img.naturalWidth == 0`、MathJax 报错（`mjx-merror`）。
3. 每页截图，拼成一张总览图，打印有问题的页号。
4. 交互页（点击、悬停）才需要人或脚本实际操作。

PDF 备份可用浏览器 `?print-pdf` 打印或 DeckTape；交互页在 PDF 里会退化为静态。
