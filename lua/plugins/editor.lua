-- 编辑基础:which-key 提示、文件树、括号、语法高亮、彩虹括号
return {
  -- which-key 显示快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        -- v3: window 已废弃,改用 win
        win = {
          border = "single",
        },
        -- v3: triggers_blacklist → triggers.disable; 默认已包含 <auto> 自动检测前缀键
        triggers = {
          { "<auto>", mode = "nxso" },
        },
      })
    end,
  },

  -- 快捷键大全（legendary：可搜索的全部快捷键 + 命令 + autocmd）
  {
    "mrjones2014/legendary.nvim",
    dependencies = {
      "nvim-telescope/telescope-ui-select.nvim", -- 用 telescope 接管 vim.ui.select，实现模糊搜索
      "folke/which-key.nvim", -- 集成 which-key 注册的键位
    },
    event = "VeryLazy",
    config = function()
      require("legendary").setup({
        -- 默认已开启 keymaps/commands/augroups/plugins 收集
        include_builtin = false,
      })
      -- 扫描所有带 desc 的全局键位，注册为"仅显示"条目（选中后回放按键，不重复绑定）
      -- 这样 legendary 才能展示 vim.keymap.set 注册的快捷键（如 core/keymaps.lua 中的）
      -- 注意：legendary 懒加载（VeryLazy），config 执行时 core/keymaps.lua 已运行完毕
      local legendary = require("legendary")
      local function scan_keymaps()
        for _, mode in ipairs({ "n", "v", "x", "o", "i", "c", "t" }) do
          for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
            local desc = km.desc
            if
              desc
              and desc ~= ""
              and desc ~= "which-key-trigger"
              and km.lhs:sub(1, 6) ~= "<Plug>"
              and km.lhs:sub(1, 5) ~= "<SNR>"
            then
              legendary.keymaps({ { km.lhs, description = desc, mode = mode } })
            end
          end
        end
      end
      scan_keymaps()
    end,
  },

  -- 快速跳转（flash：s 字符跳转 / S treesitter 节点 / r 远程跳转）
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash: jump to char" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash: jump to node" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter search",
      },
    },
  },

  -- 文件树
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        filters = {
          dotfiles = true,
        },
      })
      vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })
    end,
  },

  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {},
    config = function()
       require("nvim-treesitter.configs").setup({
         ensure_installed = { "lua", "vim", "vimdoc", "javascript", "python" },
         highlight = { enable = true },
         incremental_selection = {
           enable = true,
           keymaps = {
             init_selection = "gnn",
             node_incremental = "grn",
             scope_incremental = "grc",
             node_decremental = "grm",
           },
         },
         indent = { enable = true },
         playground = {
           enable = true,
           updatetime = 25,
           persist_queries = false,
           keybindings = {
             toggle_query_editor = 'o',
             toggle_hl_groups = 'i',
             toggle_injected_languages = 't',
             toggle_anonymous_nodes = 'a',
             toggle_language_display = 'I',
             focus_language = 'f',
             unfocus_language = 'F',
             update = 'R',
             goto_node = '<cr>',
             show_help = '?',
           },
         },
       })
       -- Fix nvim-treesitter directives for Neovim 0.12.x compatibility.
       -- Neovim 0.12 changed match:captures() to return TSNode[] per capture ID,
       -- but nvim-treesitter's master branch (archived) treats it as a single TSNode.
       -- This overrides the broken directives with TSNode[]-aware versions.
       require("custom.fix-ts-directive")
    end,
  },

  -- 自动补全括号
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
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
}
