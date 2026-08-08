-- 只读模式:安全的代码浏览模式，防止意外修改
-- 子模块:bufclass.lua(缓冲区分类)/ indicator.lua(浮窗指示器)/ autocmd.lua(BufEnter 扩展)
local bufclass = require("core.readonly.bufclass")
local indicator = require("core.readonly.indicator")

local M = {}

-- 只读模式状态
M.enabled = false
M.original_modifiable = {}
M.original_readonly = {}

-- 兼容外部调用的别名（keymaps.lua 使用）
M.should_skip = bufclass.should_skip

-- 启用只读模式
function M.enable()
  if M.enabled then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  -- 跳过特殊缓冲区
  if bufclass.should_skip(bufnr) then
    vim.notify("此缓冲区类型不支持只读模式", vim.log.levels.WARN)
    return
  end

  M.original_modifiable[bufnr] = vim.bo.modifiable
  M.original_readonly[bufnr] = vim.bo.readonly

  -- 设置当前缓冲区为只读且不可修改
  vim.bo.modifiable = false
  vim.bo.readonly = true

  -- 设置缓冲区局部变量标记只读模式
  vim.b.readonly_mode = true

  M.enabled = true
  vim.g.readonly_enabled = true
  indicator.update(true)

  vim.notify("只读模式已启用", vim.log.levels.INFO)
end

-- 禁用只读模式
function M.disable()
  if not M.enabled then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- 恢复原始设置
  if M.original_modifiable[bufnr] ~= nil then
    vim.bo.modifiable = M.original_modifiable[bufnr]
  end

  if M.original_readonly[bufnr] ~= nil then
    vim.bo.readonly = M.original_readonly[bufnr]
  end

  -- 清除缓冲区局部变量
  vim.b.readonly_mode = nil

  M.enabled = false
  vim.g.readonly_enabled = false
  indicator.update(false)

  vim.notify("只读模式已禁用", vim.log.levels.INFO)
end

-- 切换只读模式
function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

-- 为所有缓冲区设置只读模式
function M.enable_all()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      -- 跳过特殊缓冲区（如Telescope提示、浮动窗口等）
      if bufclass.should_skip(bufnr) then
        goto continue
      end

      M.original_modifiable[bufnr] = vim.api.nvim_buf_get_option(bufnr, "modifiable")
      M.original_readonly[bufnr] = vim.api.nvim_buf_get_option(bufnr, "readonly")

      vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
      vim.api.nvim_buf_set_option(bufnr, "readonly", true)
      vim.b[bufnr].readonly_mode = true
    end
    ::continue::
  end

  M.enabled = true
  vim.g.readonly_enabled = true
  indicator.update(true)
  vim.notify("所有缓冲区已设为只读模式", vim.log.levels.INFO)
end

-- 禁用所有缓冲区的只读模式
function M.disable_all()
  for bufnr, modifiable in pairs(M.original_modifiable) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      vim.api.nvim_buf_set_option(bufnr, "modifiable", modifiable)

      if M.original_readonly[bufnr] ~= nil then
        vim.api.nvim_buf_set_option(bufnr, "readonly", M.original_readonly[bufnr])
      end

      vim.b[bufnr].readonly_mode = nil
    end
  end

  -- 清除保存的状态
  M.original_modifiable = {}
  M.original_readonly = {}

  M.enabled = false
  vim.g.readonly_enabled = false
  indicator.update(false)
  vim.notify("所有缓冲区已恢复可写", vim.log.levels.INFO)
end

-- BufEnter 自动扩展（启用期间新缓冲区自动只读）
require("core.readonly.autocmd")

-- 初始化全局变量
vim.g.readonly_enabled = M.enabled

return M
