-- 轻量代码辅助：LSP 工作区符号搜索 + 导航说明（不依赖 navigator）
local M = {}

function M.setup()
  M.setup_commands()
  vim.keymap.set("n", "<leader>cm", function()
    M.create_codemap_view()
  end, { desc = "代码导航说明浮窗" })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("CodeAnalyze", function(opts)
    M.analyze_code(opts.args)
  end, { desc = "工作区符号分析 (LSP workspace/symbol)", nargs = "?" })
end

function M.analyze_code(feature)
  if not feature or feature == "" then
    local word = vim.fn.expand("<cword>")
    if word and word ~= "" then
      feature = word
    else
      vim.notify("请指定要分析的功能特性", vim.log.levels.WARN)
      return
    end
  end

  vim.notify("正在分析功能: " .. feature, vim.log.levels.INFO)

  vim.lsp.buf_request(0, "workspace/symbol", { query = feature }, function(err, result)
    if err then
      vim.notify("分析失败: " .. tostring(err.message or err), vim.log.levels.ERROR)
      return
    end

    if result and #result > 0 then
      vim.notify("找到 " .. #result .. " 个相关符号", vim.log.levels.INFO)

      local items = {}
      for _, symbol in ipairs(result) do
        table.insert(items, {
          filename = vim.uri_to_fname(symbol.location.uri),
          lnum = symbol.location.range.start.line + 1,
          col = symbol.location.range.start.character + 1,
          text = symbol.name .. " (" .. tostring(symbol.kind) .. ")",
        })
      end

      vim.fn.setqflist(items, "r")
      vim.cmd("copen")
    else
      vim.notify("未找到相关符号", vim.log.levels.WARN)
    end
  end)
end

function M.create_codemap_view()
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.8)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  local content = {
    "=== 代码导航（当前配置） ===",
    "",
    "定义/引用: gd / gr     →  LSP + Telescope（见 lua/core/keymaps.lua）",
    "工作区符号: :CodeAnalyze [query]",
    "",
    "详细键位见 :help 或 lua/core/keymaps.lua",
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")

  return { buf = buf, win = win }
end

return M
