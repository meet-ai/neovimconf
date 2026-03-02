--[[
Doom Emacs风格快捷键 for Neovim
基于Doom Emacs快捷键表的统一方案
SPC为Leader键，,为local leader
--]]

vim.g.mapleader = " "
vim.g.maplocalleader = ","

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

 -- Helper function for merged search (commands & keymaps)
 local function merged_search()
   vim.ui.select(
     { "commands", "keymaps" },
     { prompt = "Search type:" },
     function(choice)
       if choice == "commands" then
         telescope_builtin("commands")()
       elseif choice == "keymaps" then
         telescope_builtin("keymaps")()
       end
     end
   )
 end

-- ============================================================================
-- Doom Emacs风格快捷键 (SPC为Leader)
-- ============================================================================

-- 通用快捷键
map("n", "<Leader>:", "<cmd>lua vim.ui.input({prompt=':'}, function(cmd) if cmd then vim.cmd(cmd) end end)<cr>", { desc = "Execute command (M-x)" })
map("n", "<Leader>.", telescope_builtin("find_files"), { desc = "Find file" })
map("n", "<Leader>?", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show("", { mode = "n" })
  end
end, { desc = "Search keybindings (which-key)" })
map("n", "<Leader>qq", "<cmd>qa<cr>", { desc = "Quit (confirm)" })
map("n", "<Leader>qQ", "<cmd>qa!<cr>", { desc = "Force quit" })

-- ============================================================================
-- 文件操作 (SPC f)
-- ============================================================================
map("n", "<Leader>pf", telescope_builtin("find_files"), { desc = "Find file" })
map("n", "<Leader>f/", telescope_builtin("find_files"), { desc = "Find file in project" })
map("n", "<Leader>fr", telescope_builtin("oldfiles"), { desc = "Recent files" })
map("n", "<Leader>fd", telescope_builtin("find_files"), { desc = "Find directory" })
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
map("n", "<Leader>bb", telescope_builtin("buffers"), { desc = "Switch buffer" })
map("n", "<Leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>bk", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<Leader>bN", "<cmd>enew<cr>", { desc = "New empty buffer" })
map("n", "<Leader><Tab>", "<cmd>bprevious<cr>", { desc = "Switch to last buffer" })

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
map("n", "<Leader>pp", telescope_builtin("find_files"), { desc = "Switch project" })
map("n", "<Leader>pt", function() safe_cmd("NvimTreeToggle") end, { desc = "Project file tree" })
map("n", "<Leader>pr", telescope_builtin("oldfiles"), { desc = "Project recent files" })
map("n", "<Leader>p/", telescope_builtin("live_grep"), { desc = "Search in project" })
map("n", "<Leader>ot", "<cmd>ToggleTerm<cr>", { desc = "Project terminal" })

-- ============================================================================
-- 工作区 (SPC TAB)
-- ============================================================================
map("n", "<Leader><Tab>", "<cmd>lua require('telescope').extensions.workspaces.workspaces()<cr>", { desc = "Workspace menu" })
map("n", "<Leader><Tab>[", "<cmd>lua require('workspaces').previous()<cr>", { desc = "Previous workspace" })
map("n", "<Leader><Tab>]", "<cmd>lua require('workspaces').next()<cr>", { desc = "Next workspace" })
map("n", "<Leader><Tab>1", "<cmd>lua require('workspaces').open(1)<cr>", { desc = "Switch to workspace 1" })
map("n", "<Leader><Tab>2", "<cmd>lua require('workspaces').open(2)<cr>", { desc = "Switch to workspace 2" })
map("n", "<Leader><Tab>3", "<cmd>lua require('workspaces').open(3)<cr>", { desc = "Switch to workspace 3" })
map("n", "<Leader><Tab>4", "<cmd>lua require('workspaces').open(4)<cr>", { desc = "Switch to workspace 4" })
map("n", "<Leader><Tab>5", "<cmd>lua require('workspaces').open(5)<cr>", { desc = "Switch to workspace 5" })
map("n", "<Leader><Tab>6", "<cmd>lua require('workspaces').open(6)<cr>", { desc = "Switch to workspace 6" })
map("n", "<Leader><Tab>7", "<cmd>lua require('workspaces').open(7)<cr>", { desc = "Switch to workspace 7" })
map("n", "<Leader><Tab>8", "<cmd>lua require('workspaces').open(8)<cr>", { desc = "Switch to workspace 8" })
map("n", "<Leader><Tab>9", "<cmd>lua require('workspaces').open(9)<cr>", { desc = "Switch to workspace 9" })
map("n", "<Leader><Tab>n", "<cmd>lua require('workspaces').create()<cr>", { desc = "New workspace" })
map("n", "<Leader><Tab>d", "<cmd>lua require('workspaces').delete()<cr>", { desc = "Delete workspace" })
map("n", "<Leader><Tab>r", "<cmd>lua require('workspaces').rename()<cr>", { desc = "Rename workspace" })

-- ============================================================================
-- 搜索 (SPC /)
-- ============================================================================
map("n", "<Leader>/p", telescope_builtin("live_grep"), { desc = "Search in project" })
map("n", "<Leader>/P", telescope_builtin("live_grep"), { desc = "Search in another project" })
map("n", "<Leader>/d", telescope_builtin("live_grep"), { desc = "Search in directory" })
map("n", "<Leader>/D", telescope_builtin("live_grep"), { desc = "Search in selected directory" })
map("n", "<Leader>/b", telescope_builtin("current_buffer_fuzzy_find"), { desc = "Search in current buffer" })
map("n", "<Leader>/i", telescope_builtin("lsp_document_symbols"), { desc = "Symbols in current file" })
map("n", "<Leader>/I", telescope_builtin("lsp_workspace_symbols"), { desc = "Symbols in all buffers" })
map("n", "<Leader>*", telescope_builtin("grep_string"), { desc = "Search word under cursor" })
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
 map("n", "<Leader>cx", "<cmd>TroubleToggle<cr>", { desc = "Error list" })
 map("n", "<Leader>cs", function()
   local ok, aerial = pcall(require, "aerial")
   if ok then
     aerial.toggle()
   else
     vim.notify("Aerial not available", vim.log.levels.WARN)
   end
  end, { desc = "Toggle symbol outline" })
   map("n", "<Leader>cp", function()
     -- 首先检查命令是否存在
     if vim.fn.exists(":TSPlaygroundToggle") == 2 then
       vim.cmd("TSPlaygroundToggle")
       return
     end
     
     -- 尝试通过模块调用
     local ok, playground = pcall(require, "nvim-treesitter-playground")
     if ok and playground.toggle then
       playground.toggle()
       return
     end
     
     -- 如果都失败，提供安装指导
     vim.notify("Tree-sitter Playground 未安装", vim.log.levels.WARN)
     vim.notify("请运行: Lazy install nvim-treesitter/nvim-treesitter-playground", vim.log.levels.INFO)
   end, { desc = "Toggle tree-sitter playground" })
  
   map("n", "<Leader>cn", function()
     local ok, err = pcall(vim.cmd, "Navigator")
     if ok then
       vim.notify("Navigator panel opened", vim.log.levels.INFO)
     else
       vim.notify("Navigator命令错误: " .. tostring(err), vim.log.levels.ERROR)
       vim.notify("请检查navigator.lua插件是否正确安装", vim.log.levels.WARN)
     end
   end, { desc = "Open Navigator panel" })

  -- ============================================================================
 -- Git操作 (SPC g)
-- ============================================================================
map("n", "<Leader>gs", "<cmd>Neogit<cr>", { desc = "Magit status" })
map("n", "<Leader>gd", "<cmd>Neogit<cr>", { desc = "Magit dispatch menu" })
map("n", "<Leader>gc", "<cmd>Neogit commit<cr>", { desc = "Commit" })
map("n", "<Leader>gU", "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = "Unstage hunk" })
map("n", "<Leader>gt", "<cmd>GitTimeMachine<cr>", { desc = "Time machine" })

-- ============================================================================
-- 上一项/下一项 (SPC [ / SPC ])
-- ============================================================================
map("n", "<Leader>[e", "<cmd>lprev<cr>", { desc = "Previous error" })
map("n", "<Leader>]e", "<cmd>lnext<cr>", { desc = "Next error" })
map("n", "<Leader>[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>[t", "<cmd>TodoTelescope<cr>", { desc = "Previous TODO" })
map("n", "<Leader>]t", "<cmd>TodoTelescope<cr>", { desc = "Next TODO" })
map("n", "<Leader>[s", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Previous spelling error" })
map("n", "<Leader>]s", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Next spelling error" })

-- ============================================================================
-- 开关 (SPC t)
-- ============================================================================
map("n", "<Leader>tl", "<cmd>set relativenumber!<cr>", { desc = "Toggle line numbers" })
map("n", "<Leader>tf", "<cmd>lua require('toggle_check').toggle()<cr>", { desc = "Toggle flycheck" })
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

-- ============================================================================
-- 兼容性保留 (原有重要快捷键)
-- ============================================================================
map("n", "<Leader>ff", telescope_builtin("find_files"), { desc = "Find files (compat)" })
map("n", "<Leader>fg", telescope_builtin("live_grep"), { desc = "Live grep (compat)" })
map("n", "<Leader>fr", telescope_builtin("oldfiles"), { desc = "Recent files (compat)" })
map("n", "<Leader>fs", "<cmd>w<cr>", { desc = "Save file (compat)" })
map("n", "<Leader>fS", "<cmd>wa<cr>", { desc = "Save all files (compat)" })
map("n", "<Leader>bb", telescope_builtin("buffers"), { desc = "Switch buffer (compat)" })
map("n", "<Leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer (compat)" })
map("n", "<Leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer (compat)" })
map("n", "<Leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer (compat)" })
map("n", "<Leader>ww", "<C-w>w", { desc = "Cycle windows (compat)" })
map("n", "<Leader>wd", "<C-w>c", { desc = "Delete window (compat)" })
map("n", "<Leader>wD", "<C-w>o", { desc = "Delete other windows (compat)" })
map("n", "<Leader>ss", telescope_builtin("current_buffer_fuzzy_find"), { desc = "Search in buffer (compat)" })
map("n", "<Leader>sp", telescope_builtin("live_grep"), { desc = "Search in project (compat)" })
map("n", "<Leader>sf", telescope_builtin("find_files"), { desc = "Find files (compat)" })
map("n", "<Leader>sh", telescope_builtin("help_tags"), { desc = "Search help (compat)" })
map("n", "<Leader>sr", telescope_builtin("resume"), { desc = "Resume last search (compat)" })
map("n", "<Leader>jd", vim.lsp.buf.definition, { desc = "Jump to definition (compat)" })
map("n", "<Leader>jr", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Find references with preview (compat)" })
map("n", "<Leader>jD", vim.lsp.buf.declaration, { desc = "Jump to declaration (compat)" })
map("n", "<Leader>ji", vim.lsp.buf.implementation, { desc = "Jump to implementation (compat)" })
map("n", "<Leader>jt", vim.lsp.buf.type_definition, { desc = "Jump to type definition (compat)" })
map("n", "<Leader>jb", "<C-o>", { desc = "Jump back (compat)" })
map("n", "<Leader>jf", "<C-i>", { desc = "Jump forward (compat)" })
map("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol (compat)" })
map("n", "<Leader>la", vim.lsp.buf.code_action, { desc = "Code actions (compat)" })
map("n", "<Leader>lf", vim.lsp.buf.format, { desc = "Format code (compat)" })
map("n", "<Leader>ld", telescope_builtin("diagnostics"), { desc = "Show diagnostics (compat)" })
map("n", "<Leader>ls", telescope_builtin("lsp_document_symbols"), { desc = "Document symbols (compat)" })
map("n", "<Leader>lS", telescope_builtin("lsp_workspace_symbols"), { desc = "Workspace symbols (compat)" })
map("n", "<Leader>lh", vim.lsp.buf.hover, { desc = "Show documentation (compat)" })
map("n", "<Leader>h", telescope_builtin("help_tags"), { desc = "Help tags (compat)" })
map("n", "<Leader>hk", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show("", { mode = "n" })
  end
end, { desc = "Show keybindings (compat)" })
map("n", "<Leader>x", "<cmd>q<cr>", { desc = "Quit (compat)" })
map("n", "<Leader>X", "<cmd>qa<cr>", { desc = "Quit all (compat)" })
map("n", "<Leader>w", "<cmd>w<cr>", { desc = "Write (compat)" })
map("n", "<Leader>W", "<cmd>wa<cr>", { desc = "Write all (compat)" })
map("n", "<Leader>q", function()
  local win_count = vim.fn.winnr("$")
  if win_count > 1 then
    vim.cmd("wincmd w")
  end
end, { desc = "Switch to other window (compat)" })

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

-- Opencode快捷键保留
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
map({ "v", "x" }, "<Leader>aa", function() 
  local ok, opencode = pcall(require, "opencode")
  if ok and opencode.analyze_selection then
    opencode.analyze_selection()
  elseif ok and opencode.ask then
    local context = require("opencode.context").new()
    opencode.ask("", { context = context })
  else
    vim.notify("Opencode not available", vim.log.levels.WARN)
  end
end, { desc = "Opencode: analyze selection, open and chat" })
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
