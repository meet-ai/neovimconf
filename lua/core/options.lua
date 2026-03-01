--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2025-04-11 19:55:01
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2025-04-12 08:11:02
FilePath: /nvim/lua/core/options.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local opt = vim.opt

-- GUI/非终端启动时继承登录 shell 的 PATH，使 opencode/npm 等可用
do
  local shell_path_ok, shell_path = pcall(function()
    return vim.fn.system({ vim.o.shell or "zsh", "-i", "-c", "echo -n $PATH" })
  end)
  if shell_path_ok and type(shell_path) == "string" and #shell_path > 0 then
    vim.env.PATH = shell_path .. ":" .. (vim.env.PATH or "")
  end
end

-- 视觉设置
opt.number = true         -- 行号
opt.relativenumber = true -- 相对行号
opt.cursorline = true     -- 高亮当前行
opt.signcolumn = "yes"    -- 始终显示标记列
opt.linespace = 8         -- 行间距（像素，GUI 下生效；终端内需在终端设置中调整）

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

-- GUI 字体设置（适用于 Neovim GUI 版本）
if vim.fn.has("gui_running") == 1 then
  -- 使用 PT Mono 字体，h14 表示大小 14
  -- 如果系统没有安装 PT Mono，会自动使用默认字体
  vim.opt.guifont = "PT Mono:h16"
end

-- macOS/iTerm2 剪贴板支持
if vim.fn.has("mac") == 1 then
  -- 配置系统剪贴板集成
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
  -- 使用系统剪贴板（+ 寄存器）
  opt.clipboard = "unnamedplus"
else
  -- Linux/其他系统
  opt.clipboard = "unnamedplus"
end 