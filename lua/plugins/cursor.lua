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

  -- 增强注释 (类似Cursor的智能注释)
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  -- 代码注释便签（行级 annotation + 浮窗编辑）
  {
    "winter-again/annotate.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    config = function()
      require("annotate").setup({
        db_uri = vim.fn.stdpath("data") .. "/annotations_db",
        annot_sign = "󰍕",
        annot_sign_hl = "Comment",
        annot_sign_hl_current = "FloatBorder",
        annot_win_width = 30,
        annot_win_padding = 2,
      })
    end,
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
        -- 无 parser / 特殊 UI 缓冲区：rainbow lib.attach 在 parser==nil 时会报错（如 NvimTree）
        condition = function(bufnr)
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end
          local ft = vim.bo[bufnr].filetype
          local skip_ft = {
            fzfnav = true,
            ["feature-nav"] = true,
            NvimTree = true,
            ["neo-tree"] = true,
            ["neo-tree-popup"] = true,
            qf = true,
            help = true,
            lazy = true,
            lspinfo = true,
            notify = true,
          }
          if skip_ft[ft] then
            return false
          end
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return false
          end
          local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
          if not ok or parser == nil then
            return false
          end
          return true
        end,
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

  -- 更好的搜索界面
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- Cursor Agent CLI 集成（浮动终端内运行 cursor-agent）
  -- 前置：cursor-agent 需在 $PATH；详见 doc/cursor-agent-nvim.md
  {
    "xTacobaco/cursor-agent.nvim",
    lazy = true,
    cmd = { "CursorAgent", "CursorAgentSelection", "CursorAgentBuffer" },
    config = function()
      require("cursor-agent").setup({
        cmd = "cursor-agent",
        args = {},
      })
      vim.keymap.set("n", "<leader>ca", ":CursorAgent<CR>", { desc = "Cursor Agent: Toggle terminal" })
      vim.keymap.set("v", "<leader>ca", ":CursorAgentSelection<CR>", { desc = "Cursor Agent: Send selection" })
      vim.keymap.set("n", "<leader>cA", ":CursorAgentBuffer<CR>", { desc = "Cursor Agent: Send buffer" })
    end,
  },
}
