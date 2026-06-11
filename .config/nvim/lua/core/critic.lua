--| critic.lua -------------------------------------------------
-- Pandoc Lua filter: convert CriticMarkup to DOCX track changes
--
--| Mapping -----------------------------------------------------
--   {++insert++}      → w:ins   (track-change insertion)  [docx only]
--   {--delete--}      → w:del   (track-change deletion)   [docx only]
--   {~~old~>new~~}    → w:del + w:ins  (substitution)     [docx only]
--   {==highlight==}   → mark span  (preserved as Word highlight)
--   {>>comment<<}     → critic-comment Span  (rendered inline)
--
-- For non-docx output, insert/delete/subst render as styled Spans
-- (visible annotations, no track changes).
--
--| Author/Date metadata ---------------------------------------
--   pandoc draft.md -o review.docx \
--     --lua-filter=critic.lua \
--     -M author="Reviewer Name" -M date="2026-06-11"
--
--| Usage ------------------------------------------------------
-- Use a stripped format string in the wrapper:
--   -f markdown-smart-strikeout-subscript-superscript-citations
-- (default extensions mangle the markers).
--
--| Limitations ------------------------------------------------
--   - Inline content only (no block-level CriticMarkup)
--   - Comments render as visible inline spans, NOT as Word review comments
--   - Nested same-type patterns not supported (e.g. {++a{++b++}++})
--   - Brace patterns must not appear in prose
--   - Formatting (bold/italic) inside CriticMarkup is not preserved;
--     content is treated as plain text
--
--| Architecture note ------------------------------------------
-- Pandoc 3.x calls the `Str` filter BEFORE `Meta` and `Pandoc`,
-- which makes reading metadata from upvalues unreliable. We do
-- all the work in a single `Pandoc(doc)` callback: capture
-- metadata, walk the AST, and rewrite Str-containing runs in
-- place. We mutate blocks in place rather than creating copies,
-- because the metatable (which carries `t`, `tag`, etc.) does
-- not survive a naive table copy.

---| Metadata helpers -----------------------------------------
local function meta_text(meta_value)
	if meta_value == nil then
		return nil
	end
	if type(meta_value) == "string" then
		return meta_value
	end
	if type(meta_value) ~= "table" then
		return tostring(meta_value)
	end
	if meta_value.t == "MetaInlines" or meta_value.t == "MetaBlocks" then
		return pandoc.utils.stringify(meta_value)
	elseif meta_value.t == "MetaString" then
		return meta_value.text
	elseif meta_value.t == "MetaBool" then
		return tostring(meta_value.boolean)
	elseif meta_value.t == "MetaList" then
		local parts = {}
		for _, v in ipairs(meta_value) do
			local s = meta_text(v)
			if s then
				table.insert(parts, s)
			end
		end
		return table.concat(parts, ", ")
	end
	return pandoc.utils.stringify(meta_value)
end

local author = "Reviewer"
local date = os.date("%Y-%m-%dT%H:%M:%SZ")

---| ID generation --------------------------------------------
local next_id = 0
local function new_id()
	next_id = next_id + 1
	return "critic-" .. tostring(next_id)
end

---| XML escape ------------------------------------------------
local function xml_escape(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end

---| Output format detection -----------------------------------
local IS_DOCX = FORMAT == "docx"

---| Pattern matching ------------------------------------------
local function find_first(text)
	local best = nil
	local function consider(kind, s, e, c1, c2)
		if not s then
			return
		end
		if not best or s < best.s then
			best = { s = s, e = e, kind = kind, c1 = c1, c2 = c2 }
		end
	end
	-- Subst: c1 must not contain tildes (disambiguates ~~ from ~>)
	consider("subst", text:find("{~~([^~]-)~>(.-)~~}"))
	consider("insert", text:find("{%+%+(.-)%+%+}"))
	consider("delete", text:find("{%-%-(.-)%-%-}"))
	consider("highlight", text:find("{==(.-)==}"))
	consider("comment", text:find("{>>(.-)<<}"))
	if not best then
		return nil
	end
	return best.s, best.e, best.kind, best.c1, best.c2
end

---| Inline builders -------------------------------------------
local function make_run(text)
	return string.format('<w:r><w:t xml:space="preserve">%s</w:t></w:r>', xml_escape(text))
end

local function make_del_run(text)
	return string.format('<w:r><w:delText xml:space="preserve">%s</w:delText></w:r>', xml_escape(text))
end

local function docx_track(open_tag, run, close_tag)
	return pandoc.RawInline("openxml", open_tag .. run .. close_tag)
end

local function build_inline(kind, c1, c2)
	if kind == "insert" then
		if c1 == "" then
			return nil
		end
		if IS_DOCX then
			local id = new_id()
			return docx_track(
				string.format('<w:ins w:id="%s" w:author="%s" w:date="%s">', id, xml_escape(author), xml_escape(date)),
				make_run(c1),
				"</w:ins>"
			)
		else
			return pandoc.Span({ pandoc.Str("[+"), pandoc.Str(c1), pandoc.Str("+]") }, pandoc.Attr("", { "critic-insert" }))
		end
	elseif kind == "delete" then
		if c1 == "" then
			return nil
		end
		if IS_DOCX then
			local id = new_id()
			return docx_track(
				string.format('<w:del w:id="%s" w:author="%s" w:date="%s">', id, xml_escape(author), xml_escape(date)),
				make_del_run(c1),
				"</w:del>"
			)
		else
			return pandoc.Span({ pandoc.Str("[-"), pandoc.Str(c1), pandoc.Str("-]") }, pandoc.Attr("", { "critic-delete" }))
		end
	elseif kind == "subst" then
		if c1 == "" and c2 == "" then
			return nil
		end
		local nodes = {}
		if c1 ~= "" then
			if IS_DOCX then
				local id = new_id()
				table.insert(nodes, docx_track(
					string.format('<w:del w:id="%s" w:author="%s" w:date="%s">', id, xml_escape(author), xml_escape(date)),
					make_del_run(c1),
					"</w:del>"
				))
			else
				table.insert(nodes, pandoc.Span({ pandoc.Str("[-"), pandoc.Str(c1), pandoc.Str("-]") }, pandoc.Attr("", { "critic-delete" })))
			end
		end
		if c2 ~= "" then
			if IS_DOCX then
				local id = new_id()
				table.insert(nodes, docx_track(
					string.format('<w:ins w:id="%s" w:author="%s" w:date="%s">', id, xml_escape(author), xml_escape(date)),
					make_run(c2),
					"</w:ins>"
				))
			else
				table.insert(nodes, pandoc.Span({ pandoc.Str("[+"), pandoc.Str(c2), pandoc.Str("+]") }, pandoc.Attr("", { "critic-insert" })))
			end
		end
		return nodes
	elseif kind == "highlight" then
		if c1 == "" then
			return nil
		end
		return pandoc.Span({ pandoc.Str(c1) }, pandoc.Attr("", { "mark" }))
	elseif kind == "comment" then
		if c1 == "" then
			return nil
		end
		return pandoc.Span({
			pandoc.Str(" \xe2\x9c\xac "),
			pandoc.Str(c1),
		}, pandoc.Attr("", { "critic-comment" }, { title = c1 }))
	end
	return nil
end

---| Text → list of inlines ------------------------------------
local function expand(text)
	local result = {}
	while text and text ~= "" do
		local s, e, kind, c1, c2 = find_first(text)
		if not s then
			table.insert(result, pandoc.Str(text))
			break
		end
		if s > 1 then
			table.insert(result, pandoc.Str(text:sub(1, s - 1)))
		end
		local inline = build_inline(kind, c1, c2)
		if inline then
			if inline.t then
				table.insert(result, inline)
			else
				for _, n in ipairs(inline) do
					table.insert(result, n)
				end
			end
		end
		text = text:sub(e + 1)
	end
	return result
end

---| Inline list processing ------------------------------------
-- Replace contiguous runs of Str/Space with parsed inlines.
-- Mutates `inlines` in place. Returns true if any change was made.
local function process_inlines(inlines)
	if not inlines or #inlines == 0 then
		return false
	end
	local original = {}
	for i, il in ipairs(inlines) do
		original[i] = il
	end
	local n = #inlines
	local new_seq = {}
	local changed = false
	local i = 1

	local function is_text(il)
		return il.t == "Str" or il.t == "Space"
	end

	while i <= n do
		local il = original[i]
		if is_text(il) then
			local run_start = i
			while i <= n and is_text(original[i]) do
				i = i + 1
			end
			local text = ""
			for j = run_start, i - 1 do
				local x = original[j]
				if x.t == "Str" then
					text = text .. x.text
				elseif x.t == "Space" then
					text = text .. " "
				end
			end
			if not text:find("{", 1, true) then
				for j = run_start, i - 1 do
					table.insert(new_seq, original[j])
				end
			else
				local new_inlines = expand(text)
				if #new_inlines == 1 and new_inlines[1].t == "Str" and new_inlines[1].text == text then
					for j = run_start, i - 1 do
						table.insert(new_seq, original[j])
					end
				else
					changed = true
					for _, ni in ipairs(new_inlines) do
						table.insert(new_seq, ni)
					end
				end
			end
		else
			local containers = {
				Emph = true, Strong = true, Strikeout = true,
				Superscript = true, Subscript = true, SmallCaps = true,
				Underline = true, Cite = true, Link = true, Quoted = true,
				Span = true, Note = true,
			}
			if containers[il.t] and il.content and #il.content > 0 then
				if process_inlines(il.content) then
					changed = true
				end
			end
			table.insert(new_seq, il)
			i = i + 1
		end
	end

	if changed then
		for k = #inlines, 1, -1 do
			inlines[k] = nil
		end
		for _, il in ipairs(new_seq) do
			table.insert(inlines, il)
		end
		return true
	end
	return false
end

---| Block processing -----------------------------------------
local inline_containers = {
	Para = true, Plain = true, Header = true,
	Caption = true, TableCell = true,
}

local function process_block(block)
	if not block or not block.content or #block.content == 0 then
		return false
	end
	if not inline_containers[block.t] then
		return false
	end
	return process_inlines(block.content)
end

local function process_blocks(blocks)
	if not blocks then
		return false
	end
	local any_change = false
	for _, block in ipairs(blocks) do
		-- Pandoc blocks are userdata (not table) but have .t and .content
		-- Recurse into BlockQuote/Div
		if block.t == "BlockQuote" or block.t == "Div" then
			if block.content and process_blocks(block.content) then
				any_change = true
			end
		end
		-- Recurse into OrderedList/BulletList items
		if block.t == "OrderedList" or block.t == "BulletList" then
			if block.content then
				for _, item in ipairs(block.content) do
					-- item is a list of blocks (usually one Para)
					if process_blocks(item) then
						any_change = true
					end
				end
			end
		end
		-- Process the block itself for inlines
		if process_block(block) then
			any_change = true
		end
		-- Table: recurse into bodies
		if block.t == "Table" and block.bodies then
			for _, body in ipairs(block.bodies) do
				if body.body and process_blocks(body.body) then
					any_change = true
				end
			end
		end
	end
	return any_change
end

---| Main filter -----------------------------------------------
function Pandoc(doc)
	-- Capture metadata
	if doc and doc.meta then
		local a = meta_text(doc.meta.author)
		if a then
			author = a
		end
		local d = meta_text(doc.meta.date)
		if d then
			date = d
		end
	end
	-- Walk the AST and transform in place
	process_blocks(doc.blocks)
	return doc
end
