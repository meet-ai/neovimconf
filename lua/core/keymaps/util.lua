-- 键位注册公共工具
local M = {}

---同时注册 <Leader> 和 <LocalLeader>（按空格也能显示快捷键提示）
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts table|nil
function M.map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
  -- 如果是以 <Leader> 开头的映射，也注册一份到 <LocalLeader>（空格）
  if type(lhs) == "string" and lhs:find("<Leader>", 1, true) then
    local llhs = lhs:gsub("<Leader>", "<LocalLeader>")
    if llhs ~= lhs then
      local lopts = opts and vim.tbl_deep_extend("force", {}, opts) or {}
      -- 终端模式下的 <C-\><C-O> 序列不适合用 <LocalLeader> 重复注册
      if type(mode) == "string" and (mode ~= "t") then
        vim.keymap.set(mode, llhs, rhs, lopts)
      elseif type(mode) == "table" then
        local nmode = vim.tbl_filter(function(m) return m ~= "t" end, mode)
        if #nmode > 0 then
          vim.keymap.set(nmode, llhs, rhs, lopts)
        end
      end
    end
  end
end

---安全执行命令，失败时通知
function M.safe_cmd(cmd)
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify("Command failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

---安全加载 telescope builtin（未安装时通知）
---@param func_name string
function M.telescope_builtin(func_name)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin[func_name]()
    else
      vim.notify("Telescope not available", vim.log.levels.WARN)
    end
  end
end

return M
