-- Markdown 预览:render-markdown + 自定义渲染器
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = "VeryLazy",
    config = function()
       require("render-markdown").setup({
        -- 光标所在行暂时隐藏插件的渲染（overlay/conceal），显示原文，便于左右移动和编辑
        anti_conceal = {
          enabled = true,
        },
        win_options = {
          concealcursor = { rendered = "" },
        },
        pipe_table = {
          enabled = true,
          style = "normal",
          cell = "raw",
          padding = 0,
          min_width = 0,
          border_enabled = false,
          -- 行与行之间浅色分割线的高亮（虚拟行之间无分割线）
          row_divider_hl = "Comment",
        },
         link = {
           wiki = {
             body = function(ctx)
               -- 从完整路径中提取文件名
               local path = ctx.destination or ctx.text or ""
               local filename = path:match("([^/\\]+)$") or path
               return filename
             end,
           },
         },
         custom_handlers = {
           markdown = require('custom.markdown-handler'),
           markdown_inline = require('custom.markdown-inline-handler'),
         },
      })
    end,
  },
}
