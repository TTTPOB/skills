-- Pass TeX through untouched so a page-level MathJax 3 can typeset it.
-- Use together with `html-math-method: plain`.
local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function Math(el)
  local display = el.mathtype == "DisplayMath"
  local open, close = "\\(", "\\)"
  if display then open, close = "\\[", "\\]" end
  local class = display and "display" or "inline"
  return pandoc.RawInline("html",
    '<span class="math ' .. class .. '">' .. open .. escape(el.text) .. close .. '</span>')
end
