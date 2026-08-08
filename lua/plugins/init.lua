local lazy = require("lazy")

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
        -- 仅填 mason-registry 里存在的 lspconfig 名；Metals 不在 Mason 中，Scala 用 lua/lsp/init.lua 手动 cmd
        ensure_installed = {
          "jdtls",
          "gopls",
          "pyright",
          "ts_ls", -- 原 tsserver，与 nvim-lspconfig / mason-lspconfig 命名一致
          "rust_analyzer",
          "clangd",
          "marksman", -- Markdown LSP
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
        experimental = {
          ghost_text = false,
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
        -- v3: triggers_blacklist → triggers.disable; 默认已包含 <auto> 自动检测前缀键
        triggers = {
          { "<auto>", mode = "nxso" },
        },
      })
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
      require("lualine").setup({
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location', function() return vim.g.readonly_enabled and "READONLY" or "" end}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        extensions = {}
      })
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
              "%.tasty$",           -- ScalaTest 临时文件
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
              "-not", "-name", "*.tasty",
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
    dependencies = {},
    config = function()
       require("nvim-treesitter.configs").setup({
         ensure_installed = { "lua", "vim", "vimdoc", "javascript", "python", "scala" },
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

  -- Opencode.nvim - opencode CLI plugin
  {
    "nickjvandyke/opencode.nvim",
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
      -- 浮窗里显示完整 opencode TUI：用官方 `opencode.terminal`（README 推荐）。
      -- `opencode attach` 只会短暂连 HTTP 并退出，浮窗里看不到交互界面。
      -- 注意：不指定固定端口（默认随机端口）——固定端口可能与外部 `opencode serve`（如
      -- lark-channel-bridge 的远程桥接）冲突；端口被占时 opencode 会静默挂起、TUI 无法渲染。
      local opencode_term_cmd = "opencode"
      local opencode_float_w = math.floor(vim.o.columns * 0.85)
      local opencode_float_h = math.floor(vim.o.lines * 0.85)
      local opencode_float_win = {
        relative = "editor",
        width = opencode_float_w,
        height = opencode_float_h,
        row = math.floor((vim.o.lines - opencode_float_h) / 2),
        col = math.floor((vim.o.columns - opencode_float_w) / 2),
        style = "minimal",
        border = "rounded",
      }
      ---@type opencode.Opts
      -- vim.g 不能放函数、不能放混合 key 的 table，只放简单值；server/keys 稍后直接写 opts
      -- vim.g.opencode_opts 已在上面设置
      local opencode_config_ok, opencode_config = pcall(require, "opencode.config")
      if not opencode_config_ok then
        vim.notify("Failed to load opencode.config, using default config", vim.log.levels.WARN)
        opencode_config = { opts = {} }
      end
      opencode_config.opts.server = {
        start = function()
          require("opencode.terminal").start(opencode_term_cmd, opencode_float_win)
        end,
        stop = function()
          require("opencode.terminal").stop()
        end,
        toggle = function()
          require("opencode.terminal").toggle(opencode_term_cmd, opencode_float_win)
        end,
      }
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
           local ok, result = pcall(require("opencode.context").format, path)
           if ok then return result else return nil end
        end,
      })
      -- 确保 opencode 模块正确初始化
      local ok, opencode = pcall(require, "opencode")
      if ok then
        -- opencode.nvim exposes runtime APIs; no setup() on module table in current versions.
        -- Requiring the module here is enough to verify availability.
      else
        vim.notify("Failed to load opencode module: " .. tostring(opencode), vim.log.levels.ERROR)
      end
    end,
  },

  -- render-markdown.nvim - 实时Markdown预览
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

  -- 导入其他配置
  { import = "plugins.cursor" },
  { import = "plugins.configs" },
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
