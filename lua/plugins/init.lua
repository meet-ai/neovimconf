-- lazy.nvim 装配入口
-- 插件 spec 按功能域拆分:
--   plugins/lsp.lua          LSP 全家(Mason + lspconfig)
--   plugins/cmp.lua          补全(nvim-cmp)
--   plugins/editor.lua       编辑基础(which-key/nvim-tree/treesitter/autopairs/rainbow)
--   plugins/finder.lua       模糊搜索(telescope + fzf)
--   plugins/statusline.lua   状态栏(lualine)
--   plugins/ai.lua           AI 集成(opencode/copilot/cursor-agent)
--   plugins/markdown.lua     Markdown 预览(render-markdown)
--   plugins/code.lua         代码工作流(gitsigns/toggleterm/Comment/annotate)
--   plugins/colorscheme.lua  配色方案(tokyonight/gruvbox)
local lazy = require("lazy")

lazy.setup({
  { import = "plugins.lsp" },
  { import = "plugins.cmp" },
  { import = "plugins.editor" },
  { import = "plugins.finder" },
  { import = "plugins.statusline" },
  { import = "plugins.ai" },
  { import = "plugins.markdown" },
  { import = "plugins.code" },
  { import = "plugins.colorscheme" },
}, {
  -- lazy.nvim 选项配置
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "desert", "tokyonight", "gruvbox" } },
  checker = {
    enabled = true,   -- 启用插件更新检查
    notify = true,    -- 启用更新通知
    frequency = 3600, -- 每小时检查一次（秒）
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
      preview = {
        timeout = 100,
        treesitter = true,
      },
    },
  },
})
