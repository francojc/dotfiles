-- Drop DOCX presentational artifacts on the way out:
--   * highlight / underline / small-caps spans (`.mark`, `.underline`,
--     `.smallcaps`) that Pandoc would otherwise emit as `[text]{.mark}` or
--     raw `<span class="...">` markup
--   * `Underline` and `SmallCaps` inline runs
--   * quote-styled Word paragraphs that Pandoc turns into blockquotes
--
-- Content is preserved; only the formatting wrappers are removed.
--
-- Installed by home-manager to $XDG_DATA_HOME/pandoc/filters so it can be
-- referenced by bare name, e.g. `pandoc -L docx-clean.lua`.
local PRESENTATIONAL = {
  mark = true,
  underline = true,
  smallcaps = true,
  ["small-caps"] = true,
}

function Pandoc(doc)
  -- doc:walk is bottom-up, which matters for nested runs such as
  -- Span.mark > SmallCaps > Underline (e.g. "OTHER BUSINESS").
  return doc:walk {
    Span = function(el)
      for _, class in ipairs(el.classes) do
        if PRESENTATIONAL[class] then
          return el.content
        end
      end
    end,
    Underline = function(el) return el.content end,
    SmallCaps = function(el) return el.content end,
    BlockQuote = function(el) return el.content end,
  }
end
