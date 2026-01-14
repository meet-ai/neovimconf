--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2025-04-11 19:55:01
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2025-04-12 08:11:02
FilePath: /nvim/lua/core/options.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local opt = vim.opt

-- 视觉设置
opt.number = true         -- 行号
opt.relativenumber = true -- 相对行号
opt.cursorline = true     -- 高亮当前行
opt.signcolumn = "yes"    -- 始终显示标记列

-- 编辑设置
opt.expandtab = true      -- 空格替代Tab
opt.tabstop = 4           -- Tab宽度
opt.shiftwidth = 4        -- 自动缩进宽度
opt.smartindent = true    -- 智能缩进

-- 搜索设置
opt.ignorecase = true     -- 忽略大小写
opt.smartcase = true      -- 智能大小写匹配

-- 基本设置
opt.mouse = "a"
opt.clipboard = "unnamedplus"  -- 使用系统剪贴板
opt.undofile = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.updatetime = 100
opt.timeoutlen = 500

-- 缩进设置
opt.softtabstop = 2

-- 文件编码
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 其他设置
opt.wrap = false
opt.showmode = false
opt.splitbelow = true
opt.splitright = true
opt.conceallevel = 0
opt.pumheight = 10
opt.fileformat = "unix"

-- iTerm2 剪贴板支持
if vim.fn.has("mac") == 1 then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 1,
  }
end

opt.clipboard = "unnamedplus"  -- 使用系统剪贴板 