-- 表格渲染门面:聚合 parse/width/text/render 分层模块,保留 render-markdown 兼容类的 setup()/run() 公共接口
local Base = require('render-markdown.render.base')
local parse = require('custom.table.parse')
local width = require('custom.table.width')
local text = require('custom.table.text')
local render = require('custom.table.render')

---@class render.md.render.TableWrap: render.md.Render
---@field private config render.md.table.Config
---@field private data render.md.table.Data
local TableWrap = setmetatable({}, Base)
TableWrap.__index = TableWrap

-- 混合 parse/render 模块的方法,保持原类的完整方法集合(含 self: 互调)
for _, mod in ipairs({ parse, render }) do
    for method, fn in pairs(mod) do
        TableWrap[method] = fn
    end
end

---@protected
function TableWrap:run()
    -- 计算列宽（基于窗口宽度和内容宽度）
    local win_width = vim.api.nvim_win_get_width(0)
    local col_widths = width.compute_col_widths(self.data.rows, self.data.delim.cols, win_width, self.config)

    if #col_widths == 0 then
        return
    end

    -- 渲染表格
    self:render_table(col_widths)
end

return TableWrap
