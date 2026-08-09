-- Doom Emacs风格快捷键 for Neovim
-- 基于Doom Emacs快捷键表的统一方案
-- Leader 为逗号，避免与输入空格冲突；Space 为 local leader
--
-- 注意：
-- - mapleader/maplocalleader 在 init.lua 中设置（lazy.setup 之前）
-- - updatetime/timeoutlen 在 core/options.lua 中设置
-- - opencode 终端子系统在 core/keymaps/opencode.lua（require 时自动注册键位）

local map = require("core.keymaps.util").map
local safe_cmd = require("core.keymaps.util").safe_cmd
local fzf_lua = require("core.keymaps.util").fzf_lua

-- opencode 终端子系统（浮窗 toggle / t 模式转义 / 选区提取 / @file）
require("core.keymaps.opencode")

-- pi.nvim（pi coding agent 前端浮窗 / 模型 / 思考级别）
require("core.keymaps.pi")

-- ============================================================================
-- Doom Emacs风格快捷键 (SPC为Leader)
-- ============================================================================

-- 通用快捷键
map("n", "<Leader>:", "<cmd>lua vim.ui.input({prompt=':'}, function(cmd) if cmd then vim.cmd(cmd) end end)<cr>", { desc = "Execute command (M-x)" })
map("n", "<Leader>.", fzf_lua("files"), { desc = "Find file" })
map("n", "<Leader>?", function()
  -- 优先打开 legendary 全量快捷键面板；未安装/未加载时回退到 which-key 列表
  local ok = pcall(vim.cmd, "Legendary")
  if not ok then
    local wk_ok, which_key = pcall(require, "which-key")
    if wk_ok then
      which_key.show("", { mode = "n" })
    end
  end
end, { desc = "Search all keybindings (legendary)" })
map("n", "<Leader>qq", "<cmd>qa<cr>", { desc = "Quit (confirm)" })
map("n", "<Leader>qQ", "<cmd>qa!<cr>", { desc = "Force quit" })

-- ============================================================================
-- 文件操作 (SPC f)
-- ============================================================================
map("n", "<Leader>pf", fzf_lua("files"), { desc = "Find file" })
map("n", "<Leader>f/", fzf_lua("files"), { desc = "Find file in project" })
map("n", "<Leader>fr", fzf_lua("oldfiles"), { desc = "Recent files" })
map("n", "<Leader>fd", fzf_lua("files"), { desc = "Find directory" })
map("n", "<Leader>fs", "<cmd>w<cr>", { desc = "Save current file" })
map("n", "<Leader>fS", "<cmd>wa<cr>", { desc = "Save all files" })
map("n", "<Leader>fy", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied file path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file name" })
map("n", "<Leader>fR", function()
  local old_name = vim.fn.expand("%:p")
  vim.ui.input({ prompt = "New name: ", default = old_name }, function(new_name)
    if new_name then
      vim.cmd("saveas " .. new_name)
    end
  end)
end, { desc = "Rename file" })

-- ============================================================================
-- 缓冲区操作 (SPC b)
-- ============================================================================
map("n", "<Leader>bb", fzf_lua("buffers"), { desc = "Switch buffer" })
map("n", "<Leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>bk", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<Leader>bN", "<cmd>enew<cr>", { desc = "New empty buffer" })

-- ============================================================================
-- 窗口管理 (SPC w)
-- ============================================================================
map("n", "<Leader>ws", "<C-w>s", { desc = "Split below" })
map("n", "<Leader>wv", "<C-w>v", { desc = "Split right" })
map("n", "<Leader>wc", "<C-w>c", { desc = "Close window" })
map("n", "<Leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<Leader>wj", "<C-w>j", { desc = "Window down" })
map("n", "<Leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<Leader>wl", "<C-w>l", { desc = "Window right" })
map("n", "<Leader>wH", "<C-w>H", { desc = "Move window left" })
map("n", "<Leader>wJ", "<C-w>J", { desc = "Move window down" })
map("n", "<Leader>wK", "<C-w>K", { desc = "Move window up" })
map("n", "<Leader>wL", "<C-w>L", { desc = "Move window right" })
map("n", "<Leader>w=", "<C-w>=", { desc = "Balance window sizes" })
map("n", "<Leader>w+", "<cmd>resize +5<cr>", { desc = "Increase window height" })
map("n", "<Leader>w-", "<cmd>resize -5<cr>", { desc = "Decrease window height" })
map("n", "<Leader>w>", "<cmd>vertical resize +5<cr>", { desc = "Increase window width" })
map("n", "<Leader>w<", "<cmd>vertical resize -5<cr>", { desc = "Decrease window width" })
map("n", "<Leader>wm", "<C-w>_<C-w>|", { desc = "Maximize window" })

-- ============================================================================
-- 项目操作 (SPC p)
-- ============================================================================
map("n", "<Leader>pp", fzf_lua("files"), { desc = "Switch project" })
map("n", "<Leader>pt", function() safe_cmd("NvimTreeToggle") end, { desc = "Project file tree" })
map("n", "<Leader>pr", fzf_lua("oldfiles"), { desc = "Project recent files" })
map("n", "<Leader>p/", fzf_lua("grep"), { desc = "Search in project" })
map("n", "<Leader>ot", "<cmd>ToggleTerm<cr>", { desc = "Project terminal" })

map("n", "<Leader><Tab>", "<cmd>bprevious<cr>", { desc = "Switch to last buffer" })

-- ============================================================================
-- 搜索 (SPC s) - 参考 SpaceEmacs / Doom Emacs 分组
-- ============================================================================
map("n", "<Leader>ss", fzf_lua("grep"), { desc = "Search in project" })
map("n", "<Leader>sS", fzf_lua("grep"), { desc = "Search in another project" })
map("n", "<Leader>sf", fzf_lua("files"), { desc = "Find files" })
map("n", "<Leader>sd", fzf_lua("grep"), { desc = "Search in directory" })
map("n", "<Leader>sD", fzf_lua("grep"), { desc = "Search in selected directory" })
map("n", "<Leader>sb", fzf_lua("blines"), { desc = "Search in current buffer" })
map("n", "<Leader>sh", fzf_lua("help_tags"), { desc = "Search help tags" })
map("n", "<Leader>sr", fzf_lua("resume"), { desc = "Resume last search" })
map("n", "<Leader>si", fzf_lua("lsp_document_symbols"), { desc = "Symbols in current file" })
map("n", "<Leader>sI", fzf_lua("lsp_workspace_symbols"), { desc = "Symbols in all buffers" })
map("n", "<Leader>sw", fzf_lua("grep_cword"), { desc = "Search word under cursor" })
-- Evil风格高亮搜索
map("n", "*", "*", { desc = "Search word under cursor forward" })
map("n", "#", "#", { desc = "Search word under cursor backward" })

 -- ============================================================================
 -- 代码操作 (SPC c)
 -- ============================================================================
 map("n", "<Leader>cd", vim.lsp.buf.definition, { desc = "Go to definition" })
  map("n", "<Leader>cD", function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin.lsp_references()
    else
      vim.lsp.buf.references()
    end
  end, { desc = "Find references with preview" })
 map("n", "<Leader>ce", function()
   vim.cmd("source %")
   vim.notify("Buffer evaluated", vim.log.levels.INFO)
 end, { desc = "Evaluate buffer" })
 map("n", "<Leader>cb", "<cmd>make<cr>", { desc = "Compile/build" })
 map("n", "<Leader>cr", "<cmd>ToggleTerm<cr>", { desc = "REPL" })

  -- ============================================================================
 -- Git操作 (SPC g)
-- ============================================================================
map("n", "<Leader>gU", "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = "Unstage hunk" })

-- ============================================================================
-- 上一项/下一项 (SPC [ / SPC ])
-- ============================================================================
map("n", "<Leader>[e", "<cmd>lprev<cr>", { desc = "Previous error" })
map("n", "<Leader>]e", "<cmd>lnext<cr>", { desc = "Next error" })
map("n", "<Leader>[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>[s", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Previous spelling error" })
map("n", "<Leader>]s", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Next spelling error" })

-- ============================================================================
-- 开关 (SPC t)
-- ============================================================================
map("n", "<Leader>tl", "<cmd>set relativenumber!<cr>", { desc = "Toggle line numbers" })
map("n", "<Leader>ts", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })
map("n", "<Leader>tr", function()
  local ok, readonly = pcall(require, "core.readonly")
  if ok then
    readonly.toggle()
  else
    vim.notify("只读模式模块未找到", vim.log.levels.WARN)
  end
end, { desc = "Toggle read-only mode" })
map("n", "<Leader>tR", function()
  local ok, readonly = pcall(require, "core.readonly")
  if ok then
    if readonly.enabled then
      readonly.disable_all()
    else
      readonly.enable_all()
    end
  else
    vim.notify("只读模式模块未找到", vim.log.levels.WARN)
  end
end, { desc = "Toggle read-only mode for all buffers" })

-- ============================================================================
-- 折叠 (Evil z) - 使用Vim原生折叠命令
-- ============================================================================
map("n", "za", "za", { desc = "Toggle fold" })
map("n", "zc", "zc", { desc = "Close fold" })
map("n", "zr", "zr", { desc = "Open all folds" })
map("n", "zm", "zm", { desc = "Close all folds" })

-- ============================================================================
-- 列表/补全内操作 (使用Telescope默认键位)
-- ============================================================================
-- 已在Telescope映射中设置

-- 传统Vim快捷键保留
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Find references with preview" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })

map("n", "<Leader>an", function()
  local ok, annotate = pcall(require, "annotate")
  if ok then
    annotate.create_annotation()
  else
    vim.notify("annotate.nvim not available", vim.log.levels.WARN)
  end
end, { desc = "Annotation: add/edit (float)" })

map("n", "<Leader>aN", function()
  local ok, annotate = pcall(require, "annotate")
  if ok then
    annotate.delete_annotation()
  else
    vim.notify("annotate.nvim not available", vim.log.levels.WARN)
  end
end, { desc = "Annotation: delete" })

-- 插件管理快捷键保留
map("n", "<Leader>uu", function() vim.cmd("Lazy update") end, { desc = "Update all plugins" })
map("n", "<Leader>uc", function() vim.cmd("Lazy check") end, { desc = "Check for updates" })
map("n", "<Leader>us", function() vim.cmd("Lazy sync") end, { desc = "Sync plugins" })
map("n", "<Leader>uh", function() vim.cmd("Lazy home") end, { desc = "Open Lazy home" })
map("n", "<Leader>ul", function() vim.cmd("Lazy clean") end, { desc = "Clean unused plugins" })
map("n", "<Leader>ui", function() vim.cmd("Lazy install") end, { desc = "Install missing plugins" })

-- 复制粘贴快捷键保留
map("v", "<Leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<Leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
map("n", "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<Leader>P", '"+P', { desc = "Paste before cursor from system clipboard" })
map("v", "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<Leader>ya", 'gg"+yG', { desc = "Yank entire file to clipboard" })

-- 字体大小调整保留
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
