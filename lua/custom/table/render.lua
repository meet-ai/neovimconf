-- 表格 marks 渲染:分隔行与数据行的虚拟文本/虚拟行写入,mark 调用顺序与原实现一致
local str = require('render-markdown.lib.str')
local text = require('custom.table.text')

local M = {}

-- 列与列之间的空白（字符数）
local COL_SEP = '  '

---@private
---@param col_widths integer[]
function M.render_table(self, col_widths)
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
function M.render_delimiter_row(self, delim, col_widths)
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
function M.render_data_row(self, row, col_widths, is_first, is_last)
    local border = self.config.border
    local header = row.node.type == 'pipe_table_header'
    local highlight = header and self.config.head or self.config.row
    local row_divider_hl = self.config.row_divider_hl or 'Comment'

    -- 获取单元格文本并换行
    local cell_lines = {} ---@type string[][]
    local max_lines = 1

    for i, col in ipairs(row.cols) do
        local cell_text = text.get_cell_text(self.context.buf, col)
        cell_text = text.format_cell_links_for_display(cell_text, self.context.config.link)
        local max_width = col_widths[i]
        local lines = text.wrap_text(cell_text, max_width)
        cell_lines[i] = lines
        max_lines = math.max(max_lines, #lines)
    end

    -- 无竖线、全部左对齐：列之间加一点空白，对齐方式固定为 left
    local virt_lines = {} ---@type render.md.mark.Line[]

    for line_idx = 1, max_lines do
        local line_parts = {}
        for i, lines in ipairs(cell_lines) do
            local line_text = lines[line_idx] or ""
            local aligned_text = text.align_text(line_text, col_widths[i], 'left')
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

return M
