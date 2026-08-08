-- 代码工作流:Git 符号、终端、注释、代码便签
return {
  -- Git 集成 (类似Cursor的Git界面)
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

  -- 浮动终端
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

  -- 增强注释
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
}
