local M = {}

local state_by_win = {}

local function make_range(start_row, start_col, end_row, end_col)
	return {
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

local function copy_range(range)
	return make_range(range.start_row, range.start_col, range.end_row, range.end_col)
end

local function range_from_node(node)
	local start_row, start_col, end_row, end_col = node:range()
	return make_range(start_row, start_col, end_row, end_col)
end

local function pos_leq(row_a, col_a, row_b, col_b)
	return row_a < row_b or (row_a == row_b and col_a <= col_b)
end

local function pos_geq(row_a, col_a, row_b, col_b)
	return row_a > row_b or (row_a == row_b and col_a >= col_b)
end

local function range_eq(a, b)
	return a
		and b
		and a.start_row == b.start_row
		and a.start_col == b.start_col
		and a.end_row == b.end_row
		and a.end_col == b.end_col
end

local function node_contains_range(node, range)
	local start_row, start_col, end_row, end_col = node:range()
	return pos_leq(start_row, start_col, range.start_row, range.start_col)
		and pos_geq(end_row, end_col, range.end_row, range.end_col)
end

local function get_line_byte_length(bufnr, row)
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	return #line
end

local function end_exclusive_to_cursor(bufnr, range)
	if range.end_col > 0 then
		return { range.end_row + 1, range.end_col - 1 }
	end

	if range.end_row > range.start_row then
		local prev_row = range.end_row - 1
		local prev_col = math.max(get_line_byte_length(bufnr, prev_row) - 1, 0)
		return { prev_row + 1, prev_col }
	end

	return { range.end_row + 1, range.start_col }
end

local function select_range(bufnr, range)
	vim.api.nvim_win_set_cursor(0, { range.start_row + 1, range.start_col })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, end_exclusive_to_cursor(bufnr, range))
end

local function ensure_parser(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ok and parser then
		return parser
	end

	local started = pcall(vim.treesitter.start, bufnr)
	if not started then
		return nil
	end

	ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ok then
		return parser
	end

	return nil
end

local function first_named_ancestor(node)
	while node and not node:named() do
		node = node:parent()
	end
	return node
end

local function get_root_node(bufnr)
	local parser = ensure_parser(bufnr)
	if not parser then
		return nil
	end

	local trees = parser:parse(true)
	local tree = trees and trees[1]
	return tree and tree:root() or nil
end

local function get_node_at_pos(bufnr, row, col)
	if vim.treesitter.get_node then
		local ok, node = pcall(vim.treesitter.get_node, {
			bufnr = bufnr,
			pos = { row, col },
			ignore_injections = false,
		})
		if ok and node then
			return node
		end
	end

	local root = get_root_node(bufnr)
	if not root then
		return nil
	end

	return root:descendant_for_range(row, col, row, col)
end

local function get_smallest_named_node_at_cursor(bufnr)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]
	local line_len = get_line_byte_length(bufnr, row)
	local cols = { math.min(col, line_len) }

	if col > 0 then
		table.insert(cols, col - 1)
	end

	for _, candidate_col in ipairs(cols) do
		local node = first_named_ancestor(get_node_at_pos(bufnr, row, candidate_col))
		if node then
			return node
		end
	end

	return nil
end

local function get_visual_range(bufnr)
	local mode = vim.fn.mode()
	if mode == "\022" then
		vim.notify("Blockwise visual selection not supported for treesitter expand/shrink", vim.log.levels.WARN)
		return nil
	end

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	if start_pos[2] == 0 or end_pos[2] == 0 then
		return nil
	end

	local start_row = start_pos[2] - 1
	local start_col = start_pos[3] - 1
	local end_row = end_pos[2] - 1
	local end_col = end_pos[3]

	if mode == "V" then
		start_col = 0
		end_col = get_line_byte_length(bufnr, end_row)
	end

	return make_range(start_row, start_col, end_row, end_col)
end

local function get_smallest_named_node_for_range(bufnr, range)
	local node = first_named_ancestor(get_node_at_pos(bufnr, range.start_row, range.start_col))
	while node do
		if node_contains_range(node, range) then
			return node
		end
		node = first_named_ancestor(node:parent())
	end
	return nil
end

local function get_next_named_parent(node, current_range)
	local parent = first_named_ancestor(node:parent())
	while parent do
		local parent_range = range_from_node(parent)
		if not range_eq(parent_range, current_range) then
			return parent, parent_range
		end
		parent = first_named_ancestor(parent:parent())
	end
	return nil, nil
end

local function get_state(winid, bufnr)
	local state = state_by_win[winid]
	if state and state.bufnr ~= bufnr then
		state_by_win[winid] = nil
		state = nil
	end
	if not state then
		state = { bufnr = bufnr, ranges = {} }
		state_by_win[winid] = state
	end
	return state
end

function M.reset(winid)
	state_by_win[winid or vim.api.nvim_get_current_win()] = nil
end

function M.increment_selection()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	if not ensure_parser(bufnr) then
		vim.notify("No treesitter parser for current buffer", vim.log.levels.WARN)
		return
	end

	local state = get_state(winid, bufnr)
	local mode = vim.fn.mode()
	local next_range

	if mode == "v" or mode == "V" then
		local visual_range = get_visual_range(bufnr)
		if not visual_range then
			return
		end

		local node = get_smallest_named_node_for_range(bufnr, visual_range)
		if not node then
			vim.notify("No named treesitter node found for current selection", vim.log.levels.WARN)
			return
		end

		local node_range = range_from_node(node)
		local current_range = state.ranges[#state.ranges]

		if current_range and range_eq(current_range, visual_range) then
			local parent, parent_range = get_next_named_parent(node, visual_range)
			if not parent then
				return
			end
			table.insert(state.ranges, parent_range)
			next_range = parent_range
		elseif range_eq(node_range, visual_range) then
			local parent, parent_range = get_next_named_parent(node, visual_range)
			state.ranges = { copy_range(visual_range) }
			if not parent then
				return
			end
			table.insert(state.ranges, parent_range)
			next_range = parent_range
		else
			state.ranges = { node_range }
			next_range = node_range
		end
	else
		local node = get_smallest_named_node_at_cursor(bufnr)
		if not node then
			vim.notify("No named treesitter node found at cursor", vim.log.levels.WARN)
			return
		end

		next_range = range_from_node(node)
		state.ranges = { next_range }
	end

	select_range(bufnr, next_range)
end

function M.decrement_selection()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local state = state_by_win[winid]
	if not state or state.bufnr ~= bufnr or #state.ranges < 2 then
		return
	end

	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" then
		return
	end

	local visual_range = get_visual_range(bufnr)
	if not visual_range or not range_eq(visual_range, state.ranges[#state.ranges]) then
		M.reset(winid)
		return
	end

	table.remove(state.ranges)
	select_range(bufnr, state.ranges[#state.ranges])
end

return M
