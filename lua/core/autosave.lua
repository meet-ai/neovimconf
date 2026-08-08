-- 静默自动保存(安全版本):TextChanged / InsertLeave 时自动 write
-- 仅处理非只读、有关联文件、非特殊类型的缓冲区;忽略所有错误
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  callback = function()
    if vim.bo.readonly then
      return
    end

    local bufname = vim.api.nvim_buf_get_name(0)
    local buftype = vim.bo.buftype

    -- 跳过特殊缓冲区
    if bufname == "" or
       bufname:match("^term://") or
       buftype == "terminal" or
       buftype == "nofile" or
       buftype == "quickfix" or
       buftype == "prompt" then
      return
    end

    -- 检查文件是否可读
    local ok, is_readable = pcall(vim.fn.filereadable, bufname)
    if not ok or is_readable == 0 then
      return
    end

    -- 静默保存（忽略所有错误）
    pcall(vim.cmd, "silent write")
  end,
  pattern = "*",
})
