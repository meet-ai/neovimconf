-- 表格树解析:遍历 markdown AST 收集分隔行/数据行节点,构建表格行模型(setup + parse_* 系列)
local log = require('render-markdown.core.log')
local str = require('render-markdown.lib.str')

local M = {}

---@protected
---@return boolean
function M.setup(self)
    self.config = self.context.config.pipe_table
    if not self.config.enabled then
        return false
    end

    -- ensure delimiter and rows exist
    local delim_node = nil ---@type render.md.Node?
    local row_nodes = {} ---@type render.md.Node[]
    local types = {
        delim = 'pipe_table_delimiter_row',
        row = { 'pipe_table_header', 'pipe_table_row' },
        skip = { 'block_continuation' },
    }
    self.node:for_each_child(function(node)
        if node.type == types.delim then
            delim_node = node
        elseif self.context.view:overlaps(node:get()) then
            if vim.tbl_contains(types.row, node.type) then
                row_nodes[#row_nodes + 1] = node
            elseif not vim.tbl_contains(types.skip, node.type) then
                log.unhandled(self.context.buf, 'markdown', 'row', node.type)
            end
        end
    end)
    if not delim_node or #row_nodes == 0 then
        return false
    end

    -- parse delimiter row
    local delim = self:parse_delim_row(delim_node)
    if not delim then
        return false
    end

    -- 列数 = min(分隔行列数, 所有行中的最少列数)；某行因单元格内 | 被误拆时合并到最后一列
    local delim_cols = #delim.cols
    local min_cells = delim_cols
    for _, row_node in ipairs(row_nodes) do
        local pr = self:parse_row(row_node, 'pipe_table_cell')
        if pr and #pr.cells > 0 and #pr.cells < min_cells then
            min_cells = #pr.cells
        end
    end
    local expected_cols = math.min(delim_cols, min_cells)

    local rows = {} ---@type render.md.table.body.Row[]
    table.sort(row_nodes)
    for _, row_node in ipairs(row_nodes) do
        local row = self:parse_body_row(row_node, expected_cols)
        if row then
            rows[#rows + 1] = row
        end
    end
    if #rows == 0 then
        return false
    end

    local cols_trimmed = {}
    for i = 1, expected_cols do
        cols_trimmed[i] = delim.cols[i]
    end
    self.data = { delim = { node = delim.node, cols = cols_trimmed }, rows = rows }
    return true
end

---@private
---@param node render.md.Node
---@return render.md.table.delim.Row?
function M.parse_delim_row(self, node)
    local row = self:parse_row(node, 'pipe_table_delimiter_cell')
    if not row then
        return nil
    end
    ---@type render.md.table.delim.Col[]
    local cols = {}
    for _, cell in ipairs(row.cells) do
        local text = cell.text
        local left = text:match('^:?-+') or ''
        local right = text:match('-+:?$') or ''
        local alignment = 'default'
        if left:sub(1, 1) == ':' and right:sub(-1, -1) == ':' then
            alignment = 'center'
        elseif left:sub(1, 1) == ':' then
            alignment = 'left'
        elseif right:sub(-1, -1) == ':' then
            alignment = 'right'
        end
        cols[#cols + 1] = {
            width = str.width(text),
            alignment = alignment,
        }
    end
    ---@type render.md.table.delim.Row
    return { node = node, cols = cols }
end

---@private
---@param node render.md.Node
---@param expected_cols integer
---@return render.md.table.body.Row?
function M.parse_body_row(self, node, expected_cols)
    local row = self:parse_row(node, 'pipe_table_cell')
    if not row or #row.cells == 0 then
        return nil
    end
    ---@type render.md.table.body.Col[]
    local cols = {}
    local cells = row.cells
    -- 若因单元格内含有 | 导致解析出多于预期列，将多出的列合并到最后一列
    if #cells > expected_cols then
        cells = {}
        for i = 1, expected_cols - 1 do
            cells[i] = row.cells[i]
        end
        local first = row.cells[expected_cols]
        local last = row.cells[#row.cells]
        cells[expected_cols] = {
            text = nil,
            start_row = first.start_row,
            start_col = first.start_col,
            end_col = last.end_col,
            merged = true,
        }
    elseif #cells ~= expected_cols then
        return nil
    end

    for _, cell in ipairs(cells) do
        local text = cell.text
        if cell.merged then
            text = self:_get_merged_cell_text(cell)
        end
        if not text then
            text = ""
        end
        local left = 0
        local right = 0
        if text:match('^ +') then
            left = #text:match('^ +')
        end
        if text:match(' +$') then
            right = #text:match(' +$')
        end
        cols[#cols + 1] = {
            row = cell.start_row,
            start_col = cell.start_col,
            end_col = cell.end_col,
            width = str.width(text),
            space = { left = left, right = right },
            merged = cell.merged,
        }
    end
    ---@type render.md.table.body.Row
    return { node = node, pipes = row.pipes, cols = cols }
end

---@private
---@param cell table  merged cell with start_row, start_col, end_col
---@return string
function M._get_merged_cell_text(self, cell)
    local lines = vim.api.nvim_buf_get_lines(self.context.buf, cell.start_row, cell.start_row + 1, false)
    if not lines or #lines == 0 then
        return ""
    end
    local raw = lines[1]:sub(cell.start_col + 1, cell.end_col)
    -- 去掉被误解析为列分隔的 | 或全角 ｜，用空格替代
    raw = raw:gsub('%s*|%s*', ' '):gsub('%s*｜%s*', ' ')
    return raw:gsub('^%s*(.-)%s*$', '%1')
end

---@private
---@param node render.md.Node
---@param cell_type string
---@return render.md.table.Row?
function M.parse_row(self, node, cell_type)
    local pipes = {} ---@type render.md.Node[]
    local cells = {} ---@type render.md.Node[]
    node:for_each_child(function(child)
        if child.type == '|' then
            pipes[#pipes + 1] = child
        elseif child.type == cell_type then
            cells[#cells + 1] = child
        else
            log.unhandled(self.context.buf, 'markdown', 'cell', child.type)
        end
    end)
    if #pipes == 0 or #cells == 0 or #pipes ~= #cells + 1 then
        return nil
    end
    table.sort(pipes)
    table.sort(cells)
    ---@type render.md.table.Row
    return { pipes = pipes, cells = cells }
end

return M
