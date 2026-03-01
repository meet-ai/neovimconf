-- Cursor风格核心配置（无VSCode快捷键）

-- 启用Cursor风格的功能
local function enable_cursor_features()
  -- 启用相对行号
  vim.opt.number = true
  vim.opt.relativenumber = true
  
  -- 设置光标行高亮
  vim.opt.cursorline = true
  vim.opt.cursorcolumn = false
  
  -- 设置滚动偏移
  vim.opt.scrolloff = 8
  vim.opt.sidescrolloff = 8
  
  -- 设置长行处理
  vim.opt.wrap = false
  vim.opt.linebreak = true
  
  -- 设置缩进
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.smartindent = true
  
  -- 设置搜索
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  
  -- 设置UI
  vim.opt.showmatch = true
  vim.opt.showmode = false
  vim.opt.signcolumn = "yes"
  vim.opt.cmdheight = 1
  
  -- 设置鼠标
  vim.opt.mouse = "a"
  
  -- 设置终端
  vim.opt.termguicolors = true
  vim.opt.title = true
  
  -- 设置文件处理
  vim.opt.hidden = true
  vim.opt.swapfile = false
  vim.opt.backup = false
  vim.opt.undofile = true
  vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo//"
  
  -- 设置自动保存
  vim.cmd([[autocmd TextChanged,InsertLeave * if &readonly == 0 && filereadable(bufname('%')) | silent write | endif]])
  
  -- 应用Cursor风格主题
  vim.cmd([[colorscheme tokyonight]])
  vim.cmd([[set background=dark]])
end

-- 只保留Neovim原生快捷键，不添加VSCode风格快捷键
local function setup_cursor_keymaps()
  -- 保持原有Spacemacs风格的Leader键
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  
  -- 不添加任何VSCode风格的快捷键
  -- 所有功能通过Leader键组合访问
end

-- 加载Cursor风格配置
local function load_cursor_config()
  enable_cursor_features()
  setup_cursor_keymaps()
  
  -- 加载独立的Cursor快捷键模块
  local ok, keymaps = pcall(require, "cursor.keymaps")
  if ok then
    keymaps.setup()
  end
  
  -- 加载Cursor主题
  local ok, theme = pcall(require, "cursor.theme")
  if ok then
    theme.setup()
  end
end

-- 自动加载
vim.api.nvim_create_autocmd("VimEnter", {
  callback = load_cursor_config,
  once = true,
})

return {
  enable_cursor_features = enable_cursor_features,
  setup_cursor_keymaps = setup_cursor_keymaps,
  load_cursor_config = load_cursor_config,
}
