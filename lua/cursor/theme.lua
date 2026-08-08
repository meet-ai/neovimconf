-- Cursor风格主题配置

local M = {}

-- 应用Cursor风格主题覆盖
M.setup = function()
  -- 注意: 主主题已在 core/theme.lua 中设为 desert
  -- 这里只设置覆盖和自定义
  
  local is_dark = vim.o.background == "dark"
  
  -- 设置侧边栏和状态栏
  if is_dark then
     -- UI colors use plugin defaults (Spacemacs)
  else
     -- Light theme
     -- UI colors use plugin defaults (Spacemacs)
  end
  
  -- 设置语法高亮 (类似Cursor的配色)
  if is_dark then
    vim.api.nvim_set_hl(0, "Comment", { fg = "#2aa1ae", italic = true })
    vim.api.nvim_set_hl(0, "Keyword", { fg = "#4f97d7", bold = true })
    vim.api.nvim_set_hl(0, "Function", { fg = "#bc6ec5" })
    vim.api.nvim_set_hl(0, "String", { fg = "#2d9574" })
    vim.api.nvim_set_hl(0, "Number", { fg = "#a45bad" })
    vim.api.nvim_set_hl(0, "Boolean", { fg = "#a45bad" })
    vim.api.nvim_set_hl(0, "Type", { fg = "#ce537a" })
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#7590db" })
    vim.api.nvim_set_hl(0, "Constant", { fg = "#a45bad" })
  else
    -- Light theme colors - brighter and more saturated
    vim.api.nvim_set_hl(0, "Comment", { fg = "#2aa1ae", italic = true })      -- brighter teal
    vim.api.nvim_set_hl(0, "Keyword", { fg = "#3a81c3", bold = true })        -- spacemacs keyword
    vim.api.nvim_set_hl(0, "Function", { fg = "#bc6ec5", bold = true })      -- brighter purple (same as dark theme)
    vim.api.nvim_set_hl(0, "String", { fg = "#2d9574" })                     -- spacemacs str
    vim.api.nvim_set_hl(0, "Number", { fg = "#a45bad" })                     -- brighter purple
    vim.api.nvim_set_hl(0, "Boolean", { fg = "#a45bad" })                    -- brighter purple
    vim.api.nvim_set_hl(0, "Type", { fg = "#ce537a", bold = true })          -- brighter red (same as dark theme)
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#7590db" })                 -- brighter blue (same as dark theme)
    vim.api.nvim_set_hl(0, "Constant", { fg = "#a45bad" })                   -- brighter purple
  end
  
  -- 设置诊断颜色
  if is_dark then
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f38ba8" })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f9e2af" })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#89b4fa" })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#74c7ec" })
  else
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#e0446c" })  -- brighter red
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#c9a41d" })   -- brighter yellow
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#6ab0f5" })   -- brighter blue
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#2d8f5c" })   -- brighter green
  end
  
  -- 设置Git颜色
  if is_dark then
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a6e3a1" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#f9e2af" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f38ba8" })
  else
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#5aaf2d" })   -- brighter green
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#b59a1a" }) -- brighter yellow
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e0446c" }) -- brighter red
  end
  

  

  

  
  -- 设置搜索高亮
  if is_dark then
    vim.api.nvim_set_hl(0, "Search", { bg = "#fab387", fg = "#1e1e2e" })
    vim.api.nvim_set_hl(0, "IncSearch", { bg = "#f9e2af", fg = "#1e1e2e" })
  else
    vim.api.nvim_set_hl(0, "Search", { bg = "#d87c52", fg = "#fbf8ef" })  -- brighter orange, bg0
    vim.api.nvim_set_hl(0, "IncSearch", { bg = "#c9a41d", fg = "#fbf8ef" })  -- brighter yellow, bg0
  end
  

  
  -- 设置缩进线
  vim.opt.list = true
  vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
    extends = "❯",
    precedes = "❮",
  }
  if is_dark then
    vim.api.nvim_set_hl(0, "Whitespace", { fg = "#6c7086" })
  else
    vim.api.nvim_set_hl(0, "Whitespace", { fg = "#b8b4c8" })  -- brighter grey
  end
end

-- 主题切换由 core/theme.lua 的 ThemeToggle 统一负责(删除此文件中的 M.toggle_theme)

return M
