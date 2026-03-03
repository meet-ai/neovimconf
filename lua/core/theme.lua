
-- 设置主题相关配置
vim.opt.termguicolors = true  -- 启用真彩色支持

-- 设置透明背景
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

-- 加载 Spacemacs 主题
vim.o.background = "light"  -- 默认使用亮色主题
vim.cmd('colorscheme spacemacs')

-- 应用 cursor 主题覆盖
local cursor_theme_ok, cursor_theme = pcall(require, "cursor.theme")
if cursor_theme_ok and cursor_theme.setup then
  cursor_theme.setup()
end