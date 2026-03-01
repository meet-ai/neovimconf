--[[
Spacemacs-style keybindings for Neovim
Optimized and organized key mapping scheme
--]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 设置异步处理
vim.opt.updatetime = 100
vim.opt.timeoutlen = 500

local map = vim.keymap.set

-- Helper function for safe command execution
local function safe_cmd(cmd)
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify("Command failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Helper function to safely load telescope
local function telescope_builtin(func_name)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin[func_name]()
    else
      vim.notify("Telescope not available", vim.log.levels.WARN)
    end
  end
end

-- ============================================================================
-- 基础设置
-- ============================================================================
map("n", "<Leader>", "<Nop>", { desc = "Leader key" })

-- ============================================================================
-- 文件操作 (SPC f)
-- ============================================================================
map("n", "<Leader>ff", telescope_builtin("find_files"), { desc = "Find files" })
map("n", "<Leader>fr", telescope_builtin("oldfiles"), { desc = "Recent files" })
map("n", "<Leader>fg", telescope_builtin("live_grep"), { desc = "Live grep in project" })
map("n", "<Leader>fs", ":w<CR>", { desc = "Save file" })
map("n", "<Leader>fS", ":wa<CR>", { desc = "Save all files" })
map("n", "<Leader>ft", function() safe_cmd("NvimTreeToggle") end, { desc = "Toggle file tree" })

-- ============================================================================
-- 缓冲区操作 (SPC b)
-- ============================================================================
map("n", "<Leader>bb", telescope_builtin("buffers"), { desc = "Switch buffer" })
map("n", "<Leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<Leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<Leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<Leader>bs", ":w<CR>", { desc = "Save buffer" })

-- ============================================================================
-- 窗口管理 (SPC w)
-- ============================================================================
map("n", "<Leader>ww", "<C-w>w", { desc = "Cycle windows" })
map("n", "<Leader>wd", "<C-w>c", { desc = "Delete window" })
map("n", "<Leader>wD", "<C-w>o", { desc = "Delete other windows" })
map("n", "<Leader>wj", "<Plug>(choosewin)", { desc = "Jump to window" })
map("n", "<Leader>w-", "<C-w>s", { desc = "Split below" })
map("n", "<Leader>w|", "<C-w>v", { desc = "Split right" })
map("n", "<Leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<Leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<Leader>wl", "<C-w>l", { desc = "Window right" })

-- ============================================================================
-- 搜索 (SPC s)
-- ============================================================================
map("n", "<Leader>ss", telescope_builtin("current_buffer_fuzzy_find"), { desc = "Search in buffer" })
map("n", "<Leader>sp", telescope_builtin("live_grep"), { desc = "Search in project" })
map("n", "<Leader>sf", telescope_builtin("find_files"), { desc = "Find files" })
map("n", "<Leader>sh", telescope_builtin("help_tags"), { desc = "Search help" })
map("n", "<Leader>sr", telescope_builtin("resume"), { desc = "Resume last search" })
map("n", "<Leader>/", ":nohlsearch<CR>", { desc = "Clear highlights" })

-- ============================================================================
-- 跳转 (SPC j)
-- ============================================================================
map("n", "<Leader>jd", vim.lsp.buf.definition, { desc = "Jump to definition" })
map("n", "<Leader>jr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<Leader>jD", vim.lsp.buf.declaration, { desc = "Jump to declaration" })
map("n", "<Leader>ji", vim.lsp.buf.implementation, { desc = "Jump to implementation" })
map("n", "<Leader>jt", vim.lsp.buf.type_definition, { desc = "Jump to type definition" })
map("n", "<Leader>jb", "<C-o>", { desc = "Jump back" })
map("n", "<Leader>jf", "<C-i>", { desc = "Jump forward" })

-- ============================================================================
-- LSP 操作 (SPC l)
-- ============================================================================
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
map("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<Leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<Leader>lf", vim.lsp.buf.format, { desc = "Format code" })
map("n", "<Leader>ld", telescope_builtin("diagnostics"), { desc = "Show diagnostics" })
map("n", "<Leader>ls", telescope_builtin("lsp_document_symbols"), { desc = "Document symbols" })
map("n", "<Leader>lS", telescope_builtin("lsp_workspace_symbols"), { desc = "Workspace symbols" })
map("n", "<Leader>lh", vim.lsp.buf.hover, { desc = "Show documentation" })

-- ============================================================================
-- 项目操作 (SPC p)
-- ============================================================================
map("n", "<Leader>pp", telescope_builtin("find_files"), { desc = "Find files in project" })
map("n", "<Leader>ps", telescope_builtin("live_grep"), { desc = "Search in project" })
map("n", "<Leader>pb", telescope_builtin("buffers"), { desc = "Project buffers" })

-- ============================================================================
-- 代码操作 (SPC c)
-- ============================================================================
map({ "n", "t" }, "<Leader>co", function() 
  local ok, opencode = pcall(require, "opencode")
  if ok then
    opencode.toggle()
  else
    vim.notify("Opencode not loaded, trying to load plugin...", vim.log.levels.WARN)
    vim.cmd("Lazy load nickjvandyke/opencode.nvim")
    vim.defer_fn(function()
      local ok2, opencode2 = pcall(require, "opencode")
      if ok2 then
        opencode2.toggle()
      else
        vim.notify("Failed to load opencode", vim.log.levels.ERROR)
      end
    end, 100)
  end
end, { desc = "Toggle opencode" })
map({ "n", "t" }, "<Leader>cO", function() pcall(require("opencode").stop) end, { desc = "Hide opencode (close only)" })
  -- 选中代码 → 打开 opencode 并发送选区进行对话/分析（支持继续对话）
  map({ "v", "x" }, "<Leader>aa", function() 
    local ok, opencode = pcall(require, "opencode")
    if ok and opencode.analyze_selection then
      opencode.analyze_selection()
    else
      vim.notify("Opencode analyze_selection not available", vim.log.levels.WARN)
    end
  end, { desc = "Opencode: analyze selection, open and chat" })
  -- 选择文件供 opencode 使用（路径保存在 vim.g.opencode_selected_file）
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


map("n", "<Leader>q", function()
  -- 只切换焦点到其他窗口，不关闭 opencode，避免每次都要重新启动
  local win_count = vim.fn.winnr("$")
  if win_count > 1 then
    vim.cmd("wincmd w")
  end
end, { desc = "Switch to other window (keep opencode running)" })

-- ============================================================================
-- 帮助 (SPC h)
-- ============================================================================
map("n", "<Leader>h", telescope_builtin("help_tags"), { desc = "Help tags" })
map("n", "<Leader>hk", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show("", { mode = "n" })
  end
end, { desc = "Show keybindings" })

-- ============================================================================
-- 字体大小调整 (仅 GUI 下注册，避免终端里 which-key 显示无效快捷键)
-- ============================================================================
if vim.fn.has("gui_running") == 1 then
  map("n", "<Leader>=", function()
    local current_font = vim.opt.guifont:get()[1] or "PTMono-Regular:h12"
    local size = current_font:match("h(%d+)") or 12
    local new_size = math.min(tonumber(size) + 1, 24)  -- 最大 24
    local new_font = current_font:gsub("h%d+", "h" .. new_size)
    vim.opt.guifont = new_font
    vim.notify("Font size: " .. new_size, vim.log.levels.INFO)
  end, { desc = "Increase font size" })

  map("n", "<Leader>-", function()
    local current_font = vim.opt.guifont:get()[1] or "PTMono-Regular:h12"
    local size = current_font:match("h(%d+)") or 12
    local new_size = math.max(tonumber(size) - 1, 8)  -- 最小 8
    local new_font = current_font:gsub("h%d+", "h" .. new_size)
    vim.opt.guifont = new_font
    vim.notify("Font size: " .. new_size, vim.log.levels.INFO)
  end, { desc = "Decrease font size" })
end

-- ============================================================================
-- 插件管理 (SPC u)
-- ============================================================================
map("n", "<Leader>uu", function() vim.cmd("Lazy update") end, { desc = "Update all plugins" })
map("n", "<Leader>uc", function() vim.cmd("Lazy check") end, { desc = "Check for updates" })
map("n", "<Leader>us", function() vim.cmd("Lazy sync") end, { desc = "Sync plugins" })
map("n", "<Leader>uh", function() vim.cmd("Lazy home") end, { desc = "Open Lazy home" })
map("n", "<Leader>ul", function() vim.cmd("Lazy clean") end, { desc = "Clean unused plugins" })
map("n", "<Leader>ui", function() vim.cmd("Lazy install") end, { desc = "Install missing plugins" })

-- ============================================================================
-- 复制粘贴操作 (SPC y/p)
-- ============================================================================
-- 复制到系统剪贴板
map("v", "<Leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<Leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
-- 从系统剪贴板粘贴
map("n", "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<Leader>P", '"+P', { desc = "Paste before cursor from system clipboard" })
map("v", "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
-- 复制整个文件
map("n", "<Leader>ya", 'gg"+yG', { desc = "Yank entire file to clipboard" })

-- ============================================================================
-- 其他功能
-- ============================================================================
map("n", "<Leader>x", ":q<CR>", { desc = "Quit" })
map("n", "<Leader>X", ":qa<CR>", { desc = "Quit all" })
map("n", "<Leader>w", ":w<CR>", { desc = "Write" })
map("n", "<Leader>W", ":wa<CR>", { desc = "Write all" })

-- ============================================================================
-- 传统 Vim 快捷键 (保留常用快捷键)
-- ============================================================================
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
