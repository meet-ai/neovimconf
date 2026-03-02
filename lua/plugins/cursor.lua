-- Cursor风格插件配置
-- 添加类似Cursor编辑器的功能

return {
  -- Git集成 (类似Cursor的Git界面)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▎" },
          topdelete = { text = "▎" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 100,
        },
      })
    end,
  },

  -- 浮动终端 (类似Cursor的终端)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "rounded",
          width = 120,
          height = 30,
        },
      })
    end,
  },

  -- 项目管理 (类似Cursor的项目切换)
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "package.json", "pyproject.toml", "Cargo.toml" },
        silent_chdir = true,
      })
    end,
  },

  -- 代码大纲 (类似Cursor的Outline)
  {
    "stevearc/aerial.nvim",
    opts = {
      layout = {
        default_direction = "right",
        min_width = 30,
      },
      attach_mode = "global",
      show_guides = true,
    },
  },

  -- 增强注释 (类似Cursor的智能注释)
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  -- 自动补全增强 (需要 Node.js 22+)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    cond = function()
      local handle = io.popen("node -v 2>/dev/null")
      if not handle then return false end
      local version = handle:read("*a"):gsub("%s+", "")
      handle:close()
      local major = tonumber((version:match("v?(%d+)")) or "0")
      return major >= 22
    end,
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },

  -- 彩虹括号 (更好的语法高亮)
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

--[[
  -- 更好的诊断界面 (类似Cursor的问题面板)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        auto_open = false,
        auto_close = true,
        use_diagnostic_signs = true,
      })
    end,
  },
]]

  -- 浮动窗口管理 (类似Cursor的弹出窗口)
  {
    "gelguy/wilder.nvim",
    config = function()
      local wilder = require("wilder")
      wilder.setup({ modes = { ":", "/", "?" } })
      wilder.set_option("renderer", wilder.popupmenu_renderer({
        highlighter = wilder.basic_highlighter(),
        left = { " ", wilder.popupmenu_devicons() },
        right = { " ", wilder.popupmenu_scrollbar() },
      }))
    end,
  },

  -- 更好的搜索界面
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- 悬浮诊断信息
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({ virtual_lines = false })
    end,
  },
}
