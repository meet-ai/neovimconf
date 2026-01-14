--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2025-04-11 20:44:23
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2025-04-11 21:07:47
FilePath: /nvim/lua/core/keymaps.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

vim.g.mapleader = " "  -- 设置leader键为空格
vim.g.maplocalleader = " "  -- 设置local leader也为空格

-- 设置异步处理
vim.opt.updatetime = 100
vim.opt.timeoutlen = 500

-- 错误处理
local function safe_cmd(cmd)
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify("Command failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local map = vim.keymap.set

-- Doom风格SPC前缀映射
map("n", "<Leader>", "<Nop>") -- 清除默认Leader映射


-- LSP 快捷键
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format code" })

-- 文件操作 (SPC f)
map("n", "<Leader>pf", function() safe_cmd("Telescope find_files") end, { desc = "Find files" })
map("n", "<Leader>fs", ":w<CR>", { desc = "Save file" })
map("n", "<Leader>fS", ":wa<CR>", { desc = "Save all files" })

-- 缓冲区操作 (SPC b)
map("n", "<Leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<Leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<Leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- 窗口管理 (SPC w)
map("n", "<Leader>ww", "<C-w>w", { desc = "Cycle windows" })
map("n", "<Leader>wd", "<C-w>c", { desc = "Delete window" })
map("n", "<Leader>wD", "<C-w>o", { desc = "Delete other windows" })
map("n", "<Leader>wj", "<Plug>(choosewin)", { desc = "Jump to window" })
map("n", "<Leader>w-", "<C-w>s", { desc = "Split below" })
map("n", "<Leader>w|", "<C-w>v", { desc = "Split right" })

-- 搜索 (SPC s)
map("n", "<Leader>sp", function() safe_cmd("Telescope live_grep") end, { desc = "Project search" })
map("n", "<Leader>ss", function() safe_cmd("Telescope current_buffer_fuzzy_find") end, { desc = "Buffer search" })

-- 快速跳转 (SPC j)
map("n", "<Leader>jj", function() safe_cmd("lua vim.lsp.buf.definition()") end, { desc = "Jump to definition" })
map("n", "<Leader>jr", function() safe_cmd("lua vim.lsp.buf.references()") end, { desc = "Find references" })
map("n", "<Leader>jd", function() safe_cmd("lua vim.lsp.buf.declaration()") end, { desc = "Jump to declaration" })
map("n", "<Leader>ji", function() safe_cmd("lua vim.lsp.buf.implementation()") end, { desc = "Jump to implementation" })
map("n", "<Leader>jt", function() safe_cmd("lua vim.lsp.buf.type_definition()") end, { desc = "Jump to type definition" })
map("n", "<Leader>jb", "<C-o>", { desc = "Jump back" })

-- 其他功能
map("n", "<Leader>/", ":nohlsearch<CR>", { desc = "Clear highlights" }) -- 清除搜索高亮
map("n", "<Leader>q", ":q<CR>", { desc = "Quit" })                     -- 快速退出
