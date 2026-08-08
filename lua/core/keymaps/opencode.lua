-- opencode 终端子系统:浮窗 toggle、聚焦、t 模式转义、选区提取、@file 选择
-- 与普通快捷键分离：这是一个独立的功能子系统（AI 终端生命周期管理）。
-- 键位：<Leader>co / <Leader>aa / <Leader>cO / <Leader><Esc> / t:<F11> <F12> / <C-w>p
local map = require("core.keymaps.util").map

-- opencode 浮窗 toggle（懒加载插件）。
-- 原因简述（Neovim 0.12+）：
-- 1) Terminal-Job（`t`）：空格等会先给 opencode，<Leader>… 往往匹配不到映射。
-- 2) Terminal-Normal（`nt`，即 <C-\><C-n> 之后）：`nmap`/`tmap` 都不生效，<Leader>co 不会被拦截，`c`/`o`
--    会按终端缓冲区的普通键处理，容易又回到 TUI 插入态，看起来像「关不掉」。
-- 对策：`t` 下用 <C-\><C-O> 插入一帧 Normal 执行 <Cmd>lua（不经过 Leader 解析）；`nt` 下请用命令
--    :OpencodeToggleWin 或先 <C-w>p 切到普通窗口再 <Leader>co。
local function opencode_toggle_lazy()
  local function focus_opencode_terminal_if_visible()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
        local name = vim.api.nvim_buf_get_name(buf) or ""
        if name:match("term://") and name:match("opencode") then
          vim.api.nvim_set_current_win(win)
          vim.cmd("startinsert")
          return true
        end
      end
    end
    return false
  end

  local ok, opencode = pcall(require, "opencode")
  if ok then
    opencode.toggle()
    vim.schedule(function()
      focus_opencode_terminal_if_visible()
    end)
  else
    vim.notify("Opencode not loaded, trying to load plugin...", vim.log.levels.WARN)
    local loaded = pcall(vim.cmd, "Lazy load opencode.nvim")
    if not loaded then
      -- Fallback for Lazy versions/configs that still expect full plugin spec.
      pcall(vim.cmd, "Lazy load nickjvandyke/opencode.nvim")
    end
    vim.defer_fn(function()
      local ok2, opencode2 = pcall(require, "opencode")
      if ok2 then
        opencode2.toggle()
        vim.schedule(function()
          focus_opencode_terminal_if_visible()
        end)
      else
        vim.notify("Failed to load opencode", vim.log.levels.ERROR)
      end
    end, 100)
  end
end

vim.api.nvim_create_user_command("OpencodeToggleWin", function()
  opencode_toggle_lazy()
end, { desc = "切换 opencode 浮窗（任意模式可在命令行用）" })

vim.api.nvim_create_user_command("OpencodeStopWin", function()
  pcall(require("opencode").stop)
end, { desc = "关闭 opencode 终端 job（任意模式）" })

map("n", "<Leader>co", opencode_toggle_lazy, { desc = "Toggle opencode" })
-- Terminal-Job：`t` 映射 + <C-\><C-O> 让 Neovim 执行 toggle，不把 Leader 交给 PTY（与插件 README 的 <C-.> 思路一致）
vim.keymap.set(
  "t",
  "<Leader>co",
  "<C-\\><C-O><Cmd>lua require('opencode').toggle()<CR>",
  { desc = "Toggle opencode（在 opencode TUI 内）", silent = true, remap = false }
)
map("n", "<Leader>aa", opencode_toggle_lazy, { desc = "Toggle opencode (same as <Leader>co)" })
map("t", "<F12>", "<C-\\><C-O><Cmd>lua require('opencode').toggle()<CR>", { desc = "Toggle opencode（无 Leader）", silent = true, remap = false })
map("n", "<Leader>cO", function() pcall(require("opencode").stop) end, { desc = "Hide opencode (close only)" })
vim.keymap.set("t", "<Leader>cO", "<C-\\><C-O><Cmd>lua pcall(require('opencode').stop)<CR>", { silent = true, remap = false })
map("n", "<Leader><Esc>", function() pcall(require("opencode").stop) end, { desc = "Hide opencode" })
vim.keymap.set("t", "<Leader><Esc>", "<C-\\><C-O><Cmd>lua pcall(require('opencode').stop)<CR>", { silent = true, remap = false })
map("t", "<F11>", "<C-\\><C-O><Cmd>lua pcall(require('opencode').stop)<CR>", { desc = "Stop opencode（无 Leader）", silent = true, remap = false })

-- 终端插入模式：回到上一窗口；若当前是浮窗终端（如 opencode），再隐藏浮窗以免挡在「前台」，进程仍保留
local function terminal_focus_prev_and_hide_float()
  local win = vim.api.nvim_get_current_win()
  local rel = vim.api.nvim_win_get_config(win).relative
  local is_float = rel ~= nil and rel ~= ""
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-\\><C-n><C-w>p", true, true, true),
    "n",
    false
  )
  if not is_float then
    return
  end
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_hide, win)
    end
  end, 0)
end
map("t", "<C-w>p", terminal_focus_prev_and_hide_float, { desc = "Terminal: prev window; hide float if any (keep job)" })

-- 选区分析/对话:提取选中文本传给 opencode
map({ "v", "x" }, "<Leader>aa", function()
  local ok, opencode = pcall(require, "opencode")
  if ok and opencode.analyze_selection then
    opencode.analyze_selection()
  elseif ok and opencode.ask then
    local context = require("opencode.context").new()
    -- 获取选中的文本
    local selected_text = ""
    if context.range then
      local start_line = context.range.from[1]
      local start_col = context.range.from[2]
      local end_line = context.range.to[1]
      local end_col = context.range.to[2]
      local kind = context.range.kind

      -- 调整列索引：nvim_buf_get_text 期望 end_col 是排除的，而 context.range.to[2] 是包含的
      if kind == "char" or kind == "block" then
        -- 对于字符和块选择，end_col 需要加1
        end_col = end_col + 1
        -- 确保不超过行长度
        local line = vim.api.nvim_buf_get_lines(context.buf, end_line - 1, end_line, false)[1] or ""
        if end_col > #line then
          end_col = #line
        end
      elseif kind == "line" then
        -- 行选择：获取整行，列索引设为0和-1（表示行首和行尾）
        start_col = 0
        local line = vim.api.nvim_buf_get_lines(context.buf, end_line - 1, end_line, false)[1] or ""
        end_col = #line
      end

      local lines = vim.api.nvim_buf_get_text(context.buf, start_line - 1, start_col, end_line - 1, end_col, {})
      selected_text = table.concat(lines, "\n")
    end
    -- 如果有选中的文本，将其作为默认输入
    opencode.ask(selected_text, { context = context })
  else
    vim.notify("Opencode not available", vim.log.levels.WARN)
  end
end, { desc = "Opencode: analyze selection, open and chat" })

-- @file 占位符：先 <Leader>af 选文件，再在 ask 里输入 @file
map("n", "<Leader>af", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end
  builtin.find_files({
    attach_mappings = function(_, map_attach)
      map_attach("i", "<CR>", function(prompt_bufnr)
        local ok_actions, actions = pcall(require, "telescope.actions.state")
        if ok_actions then
          local sel = actions.get_selected_entry(prompt_bufnr)
          if sel and sel.value then
            vim.g.opencode_selected_file = sel.value
            vim.notify("Opencode 已选文件: " .. sel.value, vim.log.levels.INFO)
          end
        end
        require("telescope.actions").close(prompt_bufnr)
      end)
      return true
    end,
  })
end, { desc = "Select file for opencode (@file)" })
