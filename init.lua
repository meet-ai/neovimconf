-- Cursor风格Neovim配置
-- 将Neovim改造为类似Cursor编辑器的体验（无VSCode快捷键）

--[[
Cursor编辑器特性包含：
1. 现代化UI界面
2. AI编程助手集成
3. 智能项目管理
4. 强大的Git集成
5. AI增强的工作流
]]

-- Must be set before loading lazy.nvim
vim.g.mapleader = ","
vim.g.maplocalleader = " "

-- bootstrap lazy.nvim
require("core.bootstrap")

-- 加载Cursor风格核心配置
require("core.cursor")

-- 加载原始核心配置（兼容性）
require("core.options")
require("core.keymaps")
require("core.theme")

-- 在 Cursor IDE 中打开当前文件（Neovide -> Cursor）
local ok, open_in_cursor = pcall(require, "custom.open-in-cursor")
if ok then
  open_in_cursor.setup({ keymap = "<Leader>gc" })
end

-- 加载插件
require("plugins")

-- 轻量 codemap（:CodeAnalyze、<leader>cm 说明浮窗）
local ok, codemap = pcall(require, "codemap")
if ok then
  codemap.setup()
else
  vim.notify("codemap 模块加载失败，请检查 lua/codemap.lua", vim.log.levels.WARN)
end

-- 加载Cursor风格插件 (现在通过lazy.nvim导入)
-- require("plugins.cursor")

-- 启用Cursor风格主题和快捷键
vim.schedule(function()
  -- 禁用 cursor 主题覆盖（只使用 spacemacs）
  -- local ok, theme = pcall(require, "cursor.theme")
  -- if ok then
  --   theme.setup()
  -- end
  
  -- local ok, keymaps = pcall(require, "cursor.keymaps")
  -- if ok then
  --   keymaps.setup()
  -- end
  
  -- 静默模式：不显示欢迎信息
end)
