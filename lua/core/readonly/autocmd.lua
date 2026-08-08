-- 只读模式自动扩展:启用期间进入新缓冲区时自动应用只读
-- 通过回调内 lazy require 避免与 core/readonly/init.lua 的循环依赖
local readonly_augroup = vim.api.nvim_create_augroup("ReadonlyMode", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = readonly_augroup,
  callback = function(args)
    local readonly = require("core.readonly") -- 回调执行时 init 已加载完成
    if not readonly.enabled then
      return
    end
    local bufnr = args.buf
    -- 跳过特殊缓冲区
    if readonly.should_skip(bufnr) then
      return
    end
    if not readonly.original_modifiable[bufnr] then
      readonly.original_modifiable[bufnr] = vim.api.nvim_buf_get_option(bufnr, "modifiable")
      readonly.original_readonly[bufnr] = vim.api.nvim_buf_get_option(bufnr, "readonly")

      vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
      vim.api.nvim_buf_set_option(bufnr, "readonly", true)
      vim.b[bufnr].readonly_mode = true
    end
  end,
})
