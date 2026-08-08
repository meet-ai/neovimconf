-- 表格纯文本工具:单元格文本提取、链接展示转换、按宽度换行与对齐(唯一外部依赖 str.width,其余参数化注入)
local str = require('render-markdown.lib.str')

local M = {}

---@private
--- 把单元格里的 [text](path) 转成「图标 文件名」，表格 overlay 才能显示链接样式内容
---@param text string
---@param link_config table|nil
---@return string
function M.format_cell_links_for_display(text, link_config)
    if not text or #text == 0 then
        return text
    end
    local icon = (link_config and link_config.hyperlink) or '󰌹 '
    -- [任意内容](path) -> icon 文件名
    return (text:gsub('%[(.-)%]%(([^%s)]+)%)', function(_, path)
        local filename = path:match('([^/\\]+)$') or path
        return icon .. ' ' .. filename
    end))
end

---@private
---@param buf integer
---@param col render.md.table.body.Col
---@return string
function M.get_cell_text(buf, col)
    local lines = vim.api.nvim_buf_get_lines(buf, col.row, col.row + 1, false)
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
function M.wrap_text(text, width)
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
function M.align_text(text, width, alignment)
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

return M
