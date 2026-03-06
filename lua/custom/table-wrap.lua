local Base = require('render-markdown.render.base')
local iter = require('render-markdown.lib.iter')
local str = require('render-markdown.lib.str')
local log = require('render-markdown.core.log')
local Context = require('render-markdown.request.context')

 local DEBUG = false
local log = require('render-markdown.core.log')

---@class render.md.render.TableWrap: render.md.Render
---@field private config render.md.table.Config
---@field private data render.md.table.Data
local TableWrap = setmetatable({}, Base)
TableWrap.__index = TableWrap

-- 列与列之间的空白（字符数）
local COL_SEP = '  '

 ---@protected
 ---@return boolean
 function TableWrap:setup()
     self.config = self.context.config.pipe_table
    if not self.config.enabled then
        -- print("[TableWrap] Table rendering disabled in config")
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
        -- print("[TableWrap] No delimiter or rows found")
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
function TableWrap:parse_delim_row(node)
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
function TableWrap:parse_body_row(node, expected_cols)
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
function TableWrap:_get_merged_cell_text(cell)
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
function TableWrap:parse_row(node, cell_type)
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

---@protected
function TableWrap:run()
    -- print("[TableWrap] Running table renderer")
    -- 计算列宽（基于窗口宽度和内容宽度）
    local win_width = vim.api.nvim_win_get_width(0)
    local col_count = #self.data.delim.cols
    -- print("[TableWrap] Window width:", win_width, "Column count:", col_count)
    
    if col_count == 0 then
        -- print("[TableWrap] No columns, skipping")
        return
    end
    
    -- 管道符占用的宽度：每列左右各1个管道符，但最左边和最右边的管道符只算一次
    -- 表格格式：| 内容 | 内容 | 内容 |
    -- 所以总管道符宽度 = 列数 + 1
    local pipe_width = col_count + 1
    
    -- 获取填充配置
    local padding = self.config.padding or 0
    
    -- 可用宽度 = 窗口宽度 - 管道符宽度 - 填充宽度（每列左右都有填充）
    local available_width = win_width - pipe_width - (2 * padding * col_count)
    
    -- 计算每列内容的最大宽度
    local max_content_widths = {}
    for i = 1, col_count do
        max_content_widths[i] = 0
    end
    
    -- 遍历所有行，找到每列的最大内容宽度（使用已解析的col.width）
    for _, row in ipairs(self.data.rows) do
        for i, col in ipairs(row.cols) do
            max_content_widths[i] = math.max(max_content_widths[i], col.width)
        end
    end
    
    -- 也检查分隔符行的宽度（虽然没有实际内容，但影响布局）
    for i, col in ipairs(self.data.delim.cols) do
        max_content_widths[i] = math.max(max_content_widths[i], col.width)
    end
    
    local min_width = self.config.min_width or 0
    min_width = math.max(min_width, 3)

    -- 按列顺序：每列单独取 min(该列内容最大宽, 当前剩余均分)，扣减后对剩余列继续均分
    local col_widths = {}
    local remaining = available_width
    for i = 1, col_count do
        local num_left = col_count - i + 1
        local avg = math.floor(remaining / num_left)
        avg = math.max(avg, min_width)
        local cw = max_content_widths[i]
        col_widths[i] = math.max(math.min(cw, avg), min_width)
        remaining = remaining - col_widths[i]
    end

    -- 若总和仍超可用宽度（舍入导致），按比例缩
    local total_width = 0
    for i = 1, col_count do
        total_width = total_width + col_widths[i]
    end
    if total_width > available_width then
        local scale = available_width / total_width
        for i = 1, col_count do
            col_widths[i] = math.max(math.floor(col_widths[i] * scale), min_width)
        end
    end
    

    
    -- 渲染表格
    self:render_table(col_widths)
end

---@private
---@param col_widths integer[]
function TableWrap:render_table(col_widths)
    local rows = self.data.rows
    local delim = self.data.delim
    
    -- 渲染分隔符行
    self:render_delimiter_row(delim, col_widths)
    
    -- 渲染数据行
    for i, row in ipairs(rows) do
        self:render_data_row(row, col_widths, i == 1, i == #rows)
    end
end

---@private
---@param delim render.md.table.delim.Row
---@param col_widths integer[]
function TableWrap:render_delimiter_row(delim, col_widths)
    local border = self.config.border
    local icon = border[11] or '─'
    local total_width = 0
    for _, w in ipairs(col_widths) do
        total_width = total_width + w
    end
    total_width = total_width + (#col_widths - 1) * #COL_SEP
    -- 无竖线：仅一条浅色横线
    local delimiter = icon:rep(math.max(1, total_width))
    local line = self:line()
    line:pad(str.spaces('start', delim.node.text))
    line:text(delimiter, self.config.head)
    line:pad(str.width(delim.node.text) - line:width())
    
    self.marks:over(self.config, 'table_border', delim.node, {
        virt_text = line:get(),
        virt_text_pos = 'overlay',
    })
end

 ---@private
---@param row render.md.table.body.Row
---@param col_widths integer[]
---@param is_first boolean
---@param is_last boolean
function TableWrap:render_data_row(row, col_widths, is_first, is_last)
    local border = self.config.border
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row
    local row_divider_hl = self.config.row_divider_hl or 'Comment'

    -- 获取单元格文本并换行
    local cell_lines = {} ---@type string[][]
    local max_lines = 1

    for i, col in ipairs(row.cols) do
        local cell_text = self:get_cell_text(col)
        cell_text = self:format_cell_links_for_display(cell_text)
        local max_width = col_widths[i]
        local lines = self:wrap_text(cell_text, max_width)
        cell_lines[i] = lines
        max_lines = math.max(max_lines, #lines)
    end

    -- 无竖线、全部左对齐：列之间加一点空白，对齐方式固定为 left
    local virt_lines = {} ---@type render.md.mark.Line[]

    for line_idx = 1, max_lines do
        local line_parts = {}
        for i, lines in ipairs(cell_lines) do
            local line_text = lines[line_idx] or ""
            local aligned_text = self:align_text(line_text, col_widths[i], 'left')
            table.insert(line_parts, aligned_text)
        end
        local virt_text = table.concat(line_parts, COL_SEP)

        if line_idx == 1 then
            -- 先 conceal 整行，否则 overlay 比原行短时右侧 buffer 会露出来，看起来像多了一列
            self.marks:over(self.config, true, row.node, { conceal = '' })
            self.marks:over(self.config, 'table_border', row.node, {
                virt_text = { { virt_text, highlight } },
                virt_text_pos = 'overlay',
            })
        else
            table.insert(virt_lines, { { virt_text, highlight } })
        end
    end

    -- 虚拟行（同一单元格换行）不加分割线；行与行之间加浅色分割线
    if not is_last then
        local total_width = 0
        for _, w in ipairs(col_widths) do
            total_width = total_width + w
        end
        total_width = total_width + (#col_widths - 1) * #COL_SEP
        local divider_icon = border[11] or '─'
        local divider_line = divider_icon:rep(math.max(1, total_width))
        table.insert(virt_lines, { { divider_line, row_divider_hl } })
    end

    if #virt_lines > 0 then
        self.marks:add(self.config, 'virtual_lines', row.node.start_row, 0, {
            virt_lines = virt_lines,
            virt_lines_above = false,
        })
    end
end

---@private
--- 把单元格里的 [text](path) 转成「图标 文件名」，表格 overlay 才能显示链接样式内容
---@param text string
---@return string
function TableWrap:format_cell_links_for_display(text)
    if not text or #text == 0 then
        return text
    end
    local link_config = self.context.config.link
    local icon = (link_config and link_config.hyperlink) or '󰌹 '
    -- [任意内容](path) -> icon 文件名
    return (text:gsub('%[(.-)%]%(([^%s)]+)%)', function(_, path)
        local filename = path:match('([^/\\]+)$') or path
        return icon .. ' ' .. filename
    end))
end

---@private
---@param col render.md.table.body.Col
---@return string
function TableWrap:get_cell_text(col)
    local lines = vim.api.nvim_buf_get_lines(self.context.buf, col.row, col.row + 1, false)
    if not lines or #lines == 0 then
        return ""
    end
    local raw = lines[1]:sub(col.start_col + 1, col.end_col)
    if col.merged then
        raw = raw:gsub('%s*|%s*', ' '):gsub('%s*｜%s*', ' '):gsub('^%s*(.-)%s*$', '%1')
    else
        raw = raw:gsub('^%s*(.-)%s*$', '%1')
    end
    return raw
end

 ---@private
---@param text string
---@param width integer
---@return string[]
function TableWrap:wrap_text(text, width)
    if width <= 0 then return { text } end
    
    -- 如果文本为空，返回空行
    if text == "" then
        return { "" }
    end
    
    local lines = {}
    
    -- 按字符迭代，支持多字节字符
    local current_line = ""
    local current_width = 0
    
    local i = 1
    while i <= #text do
        local byte = text:byte(i)
        local char_len = 1
        
        -- 检测UTF-8字符长度
        if byte >= 0xF0 then
            char_len = 4
        elseif byte >= 0xE0 then
            char_len = 3
        elseif byte >= 0xC0 then
            char_len = 2
        end
        
        local char = text:sub(i, i + char_len - 1)
        local char_width = str.width(char)
        
        -- 如果当前字符是空格，并且是行首，跳过
        if char == " " and current_width == 0 then
            i = i + char_len
            -- 跳过本次循环的剩余部分
        else
            -- 如果添加这个字符会超过宽度，开始新行
            if current_width + char_width > width then
                if #current_line > 0 then
                    table.insert(lines, current_line)
                    current_line = ""
                    current_width = 0
                    -- 重新处理这个字符（不增加i）
                else
                    -- 当前行空，但单个字符就超过宽度，强制添加
                    table.insert(lines, char)
                    current_line = ""
                    current_width = 0
                    i = i + char_len
                end
            else
                current_line = current_line .. char
                current_width = current_width + char_width
                i = i + char_len
            end
        end
    end
    
    -- 添加最后一行
    if #current_line > 0 then
        table.insert(lines, current_line)
    end
    
    return lines
end

---@private
---@param text string
---@param width integer
---@param alignment string
---@return string
function TableWrap:align_text(text, width, alignment)
    local text_width = str.width(text)
    if text_width > width then
        -- 如果文本仍然超过宽度，进行截断（这通常不会发生，因为wrap_text应该已经处理）
        -- 但为了安全，截断并添加省略号
        local truncated = ""
        local current_width = 0
        for i = 1, #text do
            local char = text:sub(i, i)
            local char_width = str.width(char)
            if current_width + char_width <= width - 1 then
                truncated = truncated .. char
                current_width = current_width + char_width
            else
                truncated = truncated .. "…"
                break
            end
        end
        text = truncated
        text_width = str.width(text)
    end
    
    local padding = width - text_width
    
    if alignment == 'right' then
        return string.rep(' ', padding) .. text
    elseif alignment == 'center' then
        local left = math.floor(padding / 2)
        local right = padding - left
        return string.rep(' ', left) .. text .. string.rep(' ', right)
    else -- left or default
        return text .. string.rep(' ', padding)
    end
end

return TableWrap