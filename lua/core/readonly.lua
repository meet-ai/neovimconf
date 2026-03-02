-- 只读模式实现
-- 提供安全的代码浏览模式，防止意外修改

local M = {}

-- 检查是否应该跳过缓冲区（例如Telescope提示等）
local function should_skip_buffer(bufnr)
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  
  -- 跳过提示缓冲区、无文件缓冲区、弹出窗口等
  if buftype == "prompt" or buftype == "nofile" or buftype == "popup" or buftype == "acwrite" or buftype == "quickfix" or buftype == "help" or buftype == "terminal" then
    return true
  end
  
  -- 跳过特定文件类型的缓冲区
  if filetype == "TelescopePrompt" or filetype == "neo-tree" or filetype == "NvimTree" or filetype == "qf" or filetype == "help" or filetype == "fugitive" or filetype == "gitcommit" then
    return true
  end
  
  -- 可以添加其他跳过条件
  return false
end

-- 只读模式状态
M.enabled = false
M.original_modifiable = {}
M.original_readonly = {}
M.floating_win = nil
M.floating_buf = nil

-- 更新浮动窗口
local function update_floating_window()
  if M.floating_win and vim.api.nvim_win_is_valid(M.floating_win) then
    vim.api.nvim_win_close(M.floating_win, true)
    M.floating_win = nil
  end
  if M.floating_buf and vim.api.nvim_buf_is_valid(M.floating_buf) then
    vim.api.nvim_buf_delete(M.floating_buf, { force = true })
    M.floating_buf = nil
  end
  
  if M.enabled then
    -- 创建缓冲区
    M.floating_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(M.floating_buf, 0, -1, false, { " READONLY " })
    vim.api.nvim_buf_set_option(M.floating_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(M.floating_buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(M.floating_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(M.floating_buf, 'readonly', true)
    
    -- 设置高亮
    vim.api.nvim_buf_add_highlight(M.floating_buf, -1, 'WarningMsg', 0, 0, -1)
    
    -- 计算位置（右上角）
    local width = 12  -- " READONLY " 的长度
    local height = 1
    local row = 1      -- 离顶部一些间距
    local col = vim.o.columns - width - 1
    
    -- 创建窗口
    M.floating_win = vim.api.nvim_open_win(M.floating_buf, false, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      focusable = false,
      zindex = 50,
    })
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(M.floating_win, 'winhl', 'Normal:WarningMsg,NormalNC:WarningMsg')
    vim.api.nvim_win_set_option(M.floating_win, 'winblend', 20)
  end
end

-- 启用只读模式
function M.enable()
  if M.enabled then
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  -- 跳过特殊缓冲区
  if should_skip_buffer(bufnr) then
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
  update_floating_window()
  
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
  update_floating_window()
  
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
      if should_skip_buffer(bufnr) then
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
  update_floating_window()
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
  update_floating_window()
  vim.notify("所有缓冲区已恢复可写", vim.log.levels.INFO)
end

-- 自动命令：为新缓冲区设置只读模式（如果全局启用）
local readonly_augroup = vim.api.nvim_create_augroup("ReadonlyMode", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = readonly_augroup,
  callback = function(args)
    if M.enabled then
      local bufnr = args.buf
      -- 跳过特殊缓冲区
      if should_skip_buffer(bufnr) then
        return
      end
      if not M.original_modifiable[bufnr] then
        M.original_modifiable[bufnr] = vim.api.nvim_buf_get_option(bufnr, "modifiable")
        M.original_readonly[bufnr] = vim.api.nvim_buf_get_option(bufnr, "readonly")
        
        vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
        vim.api.nvim_buf_set_option(bufnr, "readonly", true)
        vim.b[bufnr].readonly_mode = true
      end
    end
  end,
})

-- 初始化全局变量
vim.g.readonly_enabled = M.enabled

return M