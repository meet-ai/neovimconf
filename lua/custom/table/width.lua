-- 表格列宽计算:输入行模型/分隔列/窗口宽度/配置 → 各列宽度(纯计算,无 vim 副作用)
local M = {}

---@private
---@param rows render.md.table.body.Row[]
---@param delim_cols render.md.table.delim.Col[]
---@param win_width integer
---@param config render.md.table.Config
---@return integer[]
function M.compute_col_widths(rows, delim_cols, win_width, config)
    local col_count = #delim_cols

    if col_count == 0 then
        return {}
    end

    -- 管道符占用的宽度：每列左右各1个管道符，但最左边和最右边的管道符只算一次
    -- 表格格式：| 内容 | 内容 | 内容 |
    -- 所以总管道符宽度 = 列数 + 1
    local pipe_width = col_count + 1

    -- 获取填充配置
    local padding = config.padding or 0

    -- 可用宽度 = 窗口宽度 - 管道符宽度 - 填充宽度（每列左右都有填充）
    local available_width = win_width - pipe_width - (2 * padding * col_count)

    -- 计算每列内容的最大宽度
    local max_content_widths = {}
    for i = 1, col_count do
        max_content_widths[i] = 0
    end

    -- 遍历所有行，找到每列的最大内容宽度（使用已解析的col.width）
    for _, row in ipairs(rows) do
        for i, col in ipairs(row.cols) do
            max_content_widths[i] = math.max(max_content_widths[i], col.width)
        end
    end

    -- 也检查分隔符行的宽度（虽然没有实际内容，但影响布局）
    for i, col in ipairs(delim_cols) do
        max_content_widths[i] = math.max(max_content_widths[i], col.width)
    end

    local min_width = config.min_width or 0
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

    return col_widths
end

return M
