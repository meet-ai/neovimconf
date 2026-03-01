-- Cursor风格主题配置

local M = {}

-- 应用Cursor风格主题
M.setup = function()
  -- 设置主题为 desert
  vim.cmd([[colorscheme desert]])
  vim.cmd([[set background=dark]])
  
  -- 启用真彩色
  vim.opt.termguicolors = true
  
  -- 设置透明背景（与 desert 主题兼容）
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  
  -- 设置侧边栏和状态栏
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "#1a1b26" })
  
  -- 设置光标和选择
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#313244" })
  vim.api.nvim_set_hl(0, "Visual", { bg = "#585b70" })
  
  -- 设置语法高亮 (类似Cursor的配色)
  vim.api.nvim_set_hl(0, "Comment", { fg = "#6272a4", italic = true })
  vim.api.nvim_set_hl(0, "Keyword", { fg = "#cba6f7", bold = true })
  vim.api.nvim_set_hl(0, "Function", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "String", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "Number", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "Boolean", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "Type", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "Identifier", { fg = "#cba6f7" })
  vim.api.nvim_set_hl(0, "Constant", { fg = "#fab387" })
  
  -- 设置诊断颜色
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#74c7ec" })
  
  -- 设置Git颜色
  vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f38ba8" })
  
  -- 设置浮动窗口样式
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "#1e1e2e", fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#585b70", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#313244" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#6c7086" })
  
  -- 设置状态栏颜色
  vim.api.nvim_set_hl(0, "StatusLine", { 
    bg = "#1e1e2e",
    fg = "#cdd6f4",
  })
  vim.api.nvim_set_hl(0, "StatusLineNC", {
    bg = "#181825",
    fg = "#6c7086",
  })
  
  -- 设置标签页
  vim.api.nvim_set_hl(0, "TabLine", { bg = "#181825", fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#1e1e2e", fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#181825" })
  
  -- 设置搜索高亮
  vim.api.nvim_set_hl(0, "Search", { bg = "#fab387", fg = "#1e1e2e" })
  vim.api.nvim_set_hl(0, "IncSearch", { bg = "#f9e2af", fg = "#1e1e2e" })
  
  -- 设置折叠
  vim.api.nvim_set_hl(0, "FoldColumn", { bg = "#1a1b26", fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "Folded", { bg = "#313244", fg = "#6c7086" })
  
  -- 设置缩进线
  vim.opt.list = true
  vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
    extends = "❯",
    precedes = "❮",
  }
  vim.api.nvim_set_hl(0, "Whitespace", { fg = "#6c7086" })
end

-- 切换主题模式
M.toggle_theme = function()
  local current_bg = vim.o.background
  if current_bg == "dark" then
    vim.cmd([[set background=light]])
    vim.cmd([[colorscheme desert]])
  else
    vim.cmd([[set background=dark]])
    vim.cmd([[colorscheme desert]])
  end
  M.setup()
end

return M
