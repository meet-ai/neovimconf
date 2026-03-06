
-- 设置主题相关配置
vim.opt.termguicolors = true  -- 启用真彩色支持

-- 设置透明背景
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

-- 加载 spacemacs 主题
local function load_theme()
  -- 只使用 spacemacs 主题
  vim.o.background = "light"
  vim.cmd('colorscheme spacemacs')
  vim.notify("使用 Spacemacs 主题", vim.log.levels.INFO)
  return true
end

-- 加载主题
load_theme()

-- 禁用 cursor 主题覆盖（只使用 spacemacs）
-- local cursor_theme_ok, cursor_theme = pcall(require, "cursor.theme")
-- if cursor_theme_ok and cursor_theme.setup then
--   cursor_theme.setup()
-- end

-- 添加主题切换命令
vim.api.nvim_create_user_command('ThemeToggle', function()
  local current = vim.g.colors_name or ''
  if current:find('tokyonight') then
    -- 切换到 gruvbox 或 spacemacs
    local gruvbox_ok, _ = pcall(require, "gruvbox")
    if gruvbox_ok then
      vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
      vim.cmd('colorscheme gruvbox')
    else
      vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
      vim.cmd('colorscheme spacemacs')
    end
  elseif current:find('gruvbox') then
    vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
    vim.cmd('colorscheme spacemacs')
  else
    -- spacemacs 切换到 tokyonight
    local tokyonight_ok, _ = pcall(require, "tokyonight")
    if tokyonight_ok then
      vim.o.background = vim.o.background == 'light' and 'light' or 'dark'
      local variant = vim.o.background == 'light' and 'tokyonight-day' or 'tokyonight-night'
      vim.cmd('colorscheme ' .. variant)
    end
  end
  
  -- 重新应用 cursor 主题
  local cursor_theme_ok, cursor_theme = pcall(require, "cursor.theme")
  if cursor_theme_ok and cursor_theme.setup then
    cursor_theme.setup()
  end
  vim.notify("切换到主题: " .. (vim.g.colors_name or 'unknown'), vim.log.levels.INFO)
end, {})