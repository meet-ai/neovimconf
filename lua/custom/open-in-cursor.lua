-- 在 Cursor IDE 中打开当前文件并切换焦点
-- macOS: 使用 Cursor.app 内 CLI，不依赖 PATH。其它系统需安装 "Shell Command: Install 'cursor'"

local M = {}

-- macOS 上 Cursor CLI 的默认路径（用于 Neovide 等 GUI 无 PATH 时）
local CURSOR_CLI_MACOS = "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

--- 获取当前缓冲区是否对应磁盘上的真实文件
local function current_file_path()
  local path = vim.api.nvim_buf_get_name(0)
  if not path or path == "" then
    return nil
  end
  local buftype = vim.api.nvim_buf_get_option(0, "buftype")
  if buftype == "nofile" or buftype == "acwrite" or buftype == "terminal" then
    return nil
  end
  return path
end

--- 返回用于打开文件的 cursor 命令（可执行路径 + 参数表）
local function cursor_open_cmd(goto_spec)
  if vim.fn.has("mac") == 1 then
    -- 优先用 App 内 CLI，保证即使用户没把 cursor 装进 PATH 也能用
    local ok = vim.fn.executable(CURSOR_CLI_MACOS) == 1
    if ok then
      return { CURSOR_CLI_MACOS, "-g", goto_spec }
    end
    -- 备选：PATH 里的 cursor
    if vim.fn.executable("cursor") == 1 then
      return { "cursor", "-g", goto_spec }
    end
    return nil
  end
  if vim.fn.executable("cursor") == 1 then
    return { "cursor", "-g", goto_spec }
  end
  return nil
end

--- 在 Cursor 中打开当前文件（可选行列）
---@param opts { line?: number, col?: number } 可选，不传则用当前光标位置
function M.open(opts)
  opts = opts or {}
  local path = current_file_path()
  if not path then
    vim.notify("当前缓冲区没有关联文件", vim.log.levels.WARN)
    return
  end

  local line = opts.line
  local col = opts.col
  if line == nil then
    local pos = vim.api.nvim_win_get_cursor(0)
    line = pos[1]
    col = pos[2] + 1
  end
  col = col or 1

  -- cursor -g "path:line:col" 才能让已运行的 Cursor 打开文件；open -a --args 在已运行时不会传参
  local goto_spec = string.format("%s:%d:%d", path, line, col)
  local cmd = cursor_open_cmd(goto_spec)
  if not cmd then
    vim.notify(
      "未找到 cursor 命令。macOS 请确认已安装 Cursor.app；其它系统请在 Cursor 内执行: Shell Command: Install 'cursor'",
      vim.log.levels.ERROR
    )
    return
  end

  vim.fn.jobstart(cmd, {
    detach = true,
    on_exit = function(_, code, _)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify("打开 Cursor 失败 (exit " .. tostring(code) .. ")", vim.log.levels.ERROR)
        end)
      else
        vim.schedule(function()
          if vim.fn.has("mac") == 1 then
            vim.fn.jobstart({ "open", "-a", "Cursor" }, { detach = true })
          end
        end)
      end
    end,
  })
  vim.notify("已在 Cursor 中打开: " .. path, vim.log.levels.INFO)
end

--- 设置命令与快捷键
function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_user_command("CursorOpen", function()
    M.open()
  end, { desc = "在 Cursor 中打开当前文件并切换焦点" })

  local keymap = opts.keymap or "<Leader>fo"
  if keymap ~= "" then
    vim.keymap.set("n", keymap, M.open, { desc = "Open in Cursor" })
  end
end

return M
