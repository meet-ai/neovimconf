-- AI 集成:opencode、pi
return {
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

  -- pi.neovim - pi coding agent Neovim 前端（零依赖，stdio RPC）
  {
    "AgenticTimes/pi.neovim",
    lazy = true,
    cmd = { "Pi", "PiToggle", "PiChat", "PiNewSession", "PiCycleModel", "PiCycleThinking", "PiDiff", "PiTermCopy" },
    config = function()
      require("pi").setup({})
      -- 禁用 nvim-cmp 对 pi 输入区的干扰：否则 / 会被 cmp 的 path 源抢成文件夹提示
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "pi://input",
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if ok and cmp.setup and cmp.setup.buffer then
            cmp.setup.buffer({ enabled = false })
          end
        end,
      })
    end,
  },
}
