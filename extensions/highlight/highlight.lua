-- highlight.lua — Quarto filter to parameterize HTML highlight color
-- Usage (project or document YAML):
--   highlight-color: "#ffec99"   # or named CSS color
-- Or nested:
--   highlight:
--     color: "#ffec99"

local stringify = pandoc.utils.stringify

local function include_style(css_text)
  if quarto and quarto.doc and quarto.doc.is_format("html") then
    quarto.doc.include_text("in-header", "<style>" .. css_text .. "</style>")
  else
    return { pandoc.RawBlock("html", "<style>" .. css_text .. "</style>") }
  end
  return {}
end

function Meta(meta)
  -- Read color from YAML
  local color = nil
  if meta["highlight-color"] then
    color = stringify(meta["highlight-color"])
  elseif meta.highlight and meta.highlight.color then
    color = stringify(meta.highlight.color)
  end

  if color and color ~= "" then
    local css = string.format(":root{--hl-color:%s}", color)
    local blocks = include_style(css)
    if #blocks > 0 then
      meta["header-includes"] = meta["header-includes"] or {}
      for _, b in ipairs(blocks) do
        table.insert(meta["header-includes"], b)
      end
    end
  end

  return meta
end

-- Ensure ==…== renders with styles regardless of writer quirks.
-- Modern Pandoc emits <mark> for ==…== in HTML; older versions may use
-- <span class="mark">. Our CSS targets both, so we don't need to rewrite.
-- Keep Span hook for potential future tweaks while returning nil (no-op).
function Span(el)
  return nil
end

