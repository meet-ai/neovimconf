--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2025-04-11 19:55:01
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2025-04-11 20:53:16
FilePath: /nvim/lua/plugins/init.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local lazy = require("lazy")

-- 主题配置 - 使用内置的 desert 主题
vim.cmd.colorscheme("default")

lazy.setup({
  -- Mason 插件管理器
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "jdtls",
          "gopls",
          "pyright",
          "tsserver",
          "rust_analyzer",
          "clangd",
          "metals",
        },
      })
    end,
  },

  -- LSP 相关插件
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("lsp.init")
    end,
  },

  -- nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind-nvim",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
      })

      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  

  -- which-key 显示快捷键提示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        window = {
          border = "single",
        },
        triggers_blacklist = {
          i = { "j", "k" },
          v = { "j", "k" },
        },
      })
    end,
  },
  { 'wakatime/vim-wakatime', lazy = false },
  {
    'stevearc/aerial.nvim',
    opts = {},

    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require('aerial').setup({
        -- 设置布局为右侧
        layout = {
          default_direction = "right",
          placement = "edge",
          width = 30,
        },
        -- 在特定文件类型下自动打开
        attach_mode = "global",
        -- 设置文件类型
      })
    end,
  },
  {
    "t9md/vim-choosewin",
    config = function()
        vim.g.choosewin_overlay_enable = 1        -- 启用覆盖模式
        vim.g.choosewin_statusline_replace = 1    -- 替换状态栏
        vim.g.choosewin_tabline_replace = 0       -- 不替换标签栏
        vim.g.choosewin_color_overlay = {
            gui = { '#88c0d0', '#434C5E' },       -- 设置覆盖颜色
            cterm = { 'blue', 'black' }
        }
        vim.g.choosewin_color_overlay_current = {
            gui = { '#88c0d0', '#434C5E' },
            cterm = { 'blue', 'black' }
        }
    end,
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
    end,
  },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  -- 模糊搜索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          -- 让搜索结果显示文件路径
          path_display = { "smart" },
          -- 文件搜索时忽略的目录/模式（减少 Scala 等编译产物干扰）
          file_ignore_patterns = {
            "^%.git/",
            "^node_modules/",
            "^target/",           -- sbt / Scala 编译输出
            "^%.bloop/",          -- Bloop
            "^%.metals/",         -- Metals
            "^%.bsp/",
            "^project/target/",   -- sbt project 编译
            "%.class$",           -- JVM 字节码
            "%.jar$",             -- 如需也排除 jar 可保留
          },
        },
        pickers = {
          find_files = {
            -- 包含隐藏文件，但排除 .git 及编译目录
            hidden = true,
            find_command = {
              "find", ".", "-type", "f",
              "-not", "-path", "*/.git/*",
              "-not", "-path", "*/target/*",
              "-not", "-path", "*/.bloop/*",
              "-not", "-path", "*/.metals/*",
              "-not", "-path", "*/.bsp/*",
              "-not", "-path", "*/node_modules/*",
              "-not", "-name", "*.class",
            },
          },
        },
      })
    end,
  },

  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
         ensure_installed = { "lua", "vim", "vimdoc", "javascript", "python", "scala" },
        highlight = { enable = true },
      })
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

  -- Opencode.nvim - opencode CLI plugin
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    lazy = true,
    cmd = { "Opencode", "OpencodeToggle" },
    -- 快捷键已统一放在 lua/core/keymaps.lua，便于 which-key 显示（GUI/终端一致）
    config = function()
      vim.o.autoread = true
      -- 完全禁用 ask 模态对话框
      vim.g.opencode_opts = {
        ask = {
          snacks = {
            win = {
              border = "rounded",
              width = 0.8,
              height = 0.8,
            },
          },
        },
      }
      -- 插件默认 server 会 require("opencode.terminal")，该模块仓库中不存在，故自实现 start/stop/toggle
      local opencode_server_buf = nil
      local opencode_server_win = nil
      -- 通过 termopen 默认 buffer 名 term://...opencode 查找已有窗口（不用固定名，避免 "name already exists"）
       local function opencode_find_existing_win()
         for _, win in ipairs(vim.api.nvim_list_wins()) do
           if vim.api.nvim_win_is_valid(win) then
             local buf = vim.api.nvim_win_get_buf(win)
             if vim.api.nvim_buf_is_valid(buf) then
               local name = vim.api.nvim_buf_get_name(buf)
               if name and name:find("term://") and name:find("opencode") then
                 return win
               end
             end
           end
         end
         return nil
       end

        local function opencode_find_existing_buf()
          -- 首先检查已有的变量是否有效
          if opencode_server_buf and vim.api.nvim_buf_is_valid(opencode_server_buf) then
            return opencode_server_buf
          end
          -- 遍历所有缓冲区，查找终端缓冲区或名称匹配的
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) then
              local name = vim.api.nvim_buf_get_name(buf)
              local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
              -- 检查是否为终端缓冲区且名称包含 opencode
              if buftype == "terminal" then
                if name and name:find("opencode") then
                  return buf
                end
                -- 如果没有名称匹配，但可能是 opencode 终端（通过其他方式识别）
                -- 我们可以检查缓冲区内容或作业状态，但暂时只检查名称
              end
            end
          end
          return nil
        end

        local function opencode_close_win()
          local win = opencode_server_win or (vim.g.opencode_embed_winid and vim.g.opencode_embed_winid or nil)
          if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          opencode_server_win = nil
          -- 不清除 opencode_server_buf，以便后续重新打开窗口
          vim.g.opencode_embed_winid = nil
        end
        -- 暴露给全局，供终端模式映射使用
        vim.g.opencode_close_win = opencode_close_win

       local function opencode_embed_toggle()
         local win = opencode_find_existing_win()
         if win then
           opencode_server_win = win
           opencode_server_buf = vim.api.nvim_win_get_buf(win)
           -- 当前就在 opencode 窗口：只切走焦点（隐藏），不关闭
           if vim.api.nvim_get_current_win() == win then
             if vim.fn.winnr("$") > 1 then
               vim.cmd("wincmd w")
             end
             return
           end
           -- 在别的窗口：聚焦到 opencode
           vim.api.nvim_set_current_win(win)
           return
         end
          -- 没有现有窗口，查找现有缓冲区
          local buf = opencode_find_existing_buf()
           if buf then
             opencode_server_buf = buf
             -- 缓冲区存在但没有窗口，重新打开窗口
             vim.notify("Found existing opencode buffer", vim.log.levels.INFO)
              -- 确保有 <C-q> 映射（可能已存在，但覆盖也无妨）
              vim.api.nvim_buf_set_keymap(opencode_server_buf, "n", "<C-q>", "", {
                callback = opencode_close_win,
                noremap = true,
                silent = true,
              })
              vim.api.nvim_buf_set_keymap(opencode_server_buf, "t", "<C-q>", "<C-\\><C-n><cmd>lua vim.g.opencode_close_win()<CR>", { noremap = true, silent = true })
              -- Esc 退出终端插入模式
              vim.api.nvim_buf_set_keymap(opencode_server_buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
          else
             -- 创建新缓冲区
             vim.notify("Creating new opencode buffer", vim.log.levels.INFO)
             opencode_server_buf = vim.api.nvim_create_buf(false, true)
            -- 绑定 <C-q> 关闭窗口（隐藏）
            vim.api.nvim_buf_set_keymap(opencode_server_buf, "n", "<C-q>", "", {
              callback = opencode_close_win,
              noremap = true,
              silent = true,
            })
            vim.api.nvim_create_autocmd("TermClose", {
              buffer = opencode_server_buf,
              once = true,
              callback = function()
                if opencode_server_win and vim.api.nvim_win_is_valid(opencode_server_win) then
                  vim.api.nvim_win_close(opencode_server_win, true)
                end
                opencode_server_win = nil
                opencode_server_buf = nil
                vim.g.opencode_embed_winid = nil
              end,
            })
               vim.api.nvim_buf_set_keymap(opencode_server_buf, "t", "<C-q>", "<C-\\><C-n><cmd>lua vim.g.opencode_close_win()<CR>", { noremap = true, silent = true })
               -- Esc 退出终端插入模式
               vim.api.nvim_buf_set_keymap(opencode_server_buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
                vim.fn.termopen("opencode attach http://127.0.0.1:28080", { cwd = vim.loop.cwd() })
         end
         -- 现在打开窗口（无论是现有缓冲区还是新缓冲区）
         local width = math.floor(vim.o.columns * 0.8)
         local height = math.floor(vim.o.lines * 0.8)
         local row = math.floor((vim.o.lines - height) / 2)
         local col = math.floor((vim.o.columns - width) / 2)
          opencode_server_win = vim.api.nvim_open_win(opencode_server_buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
          })
          vim.g.opencode_embed_winid = opencode_server_win
          -- 如果是终端缓冲区，进入插入模式
          if vim.api.nvim_buf_is_valid(opencode_server_buf) then
            local buftype = vim.api.nvim_buf_get_option(opencode_server_buf, "buftype")
            if buftype == "terminal" then
              vim.cmd("startinsert")
            end
          end
       end
       ---@type opencode.Opts
       -- vim.g 不能放函数、不能放混合 key 的 table，只放简单值；server/keys 稍后直接写 opts
       -- vim.g.opencode_opts 已在上面设置
      local opencode_config = require("opencode.config")
        opencode_config.opts.server = {
          start = function()
            if not (opencode_server_win and vim.api.nvim_win_is_valid(opencode_server_win)) then
              opencode_embed_toggle()
            end
          end,
           stop = function()
             opencode_close_win()
           end,
          toggle = opencode_embed_toggle,
        }
        opencode_config.opts.cmd = {"opencode", "attach", "http://127.0.0.1:28080"}
      -- 输入栏关闭/取消：Ctrl+Q、Esc
      if opencode_config.opts.ask and opencode_config.opts.ask.snacks and opencode_config.opts.ask.snacks.win then
        local win_keys = opencode_config.opts.ask.snacks.win.keys or {}
        win_keys.ctrl_q_cancel = { "<C-q>", "cancel", mode = "i" }
        win_keys.i_esc_cancel = { "<Esc>", { "stopinsert", "cancel" }, mode = "i" }
        opencode_config.opts.ask.snacks.win.keys = win_keys
      end
      -- @file 占位符：先 <Leader>af 选文件，再在 ask 里输入 @file
      opencode_config.opts.contexts = vim.tbl_extend("force", opencode_config.opts.contexts or {}, {
        ["@file"] = function(ctx)
          local path = vim.g.opencode_selected_file
          if not path or path == "" then return nil end
          return require("opencode.context").format(path)
        end,
      })
      -- 确保 opencode 模块正确初始化
      require("opencode").setup()
    end,
  },

  -- 导入其他配置
  { import = "plugins.cursor" },
  { import = "plugins.configs" },
}, {
  -- lazy.nvim 选项配置
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "gruvbox" } },
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
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
