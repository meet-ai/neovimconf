
-- 设置主题相关配置
vim.opt.termguicolors = true  -- 启用真彩色支持

-- 设置透明背景
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

-- 如果你想使用特定的配色方案，可以在这里设置
-- 例如使用 tokyonight 主题：
-- vim.cmd[[colorscheme tokyonight]]

-- 默认使用内置的配色方案
vim.cmd[[colorscheme slate]]