-- LSP 公共工具:capabilities、服务器可用性探测、路径工具
local M = {}

-- 共享 capabilities(基于 cmp 的 LSP capabilities)
M.capabilities = require("cmp_nvim_lsp").default_capabilities()

---检查 LSP 服务器是否可用(静默模式)
---有副作用:命中 mason 目录时会用 mason 绝对路径替换 cmd_list[1]
---@param cmd_list string[]
---@return boolean
function M.check_server_availability(cmd_list)
  if not cmd_list or not cmd_list[1] then
    return false
  end
  local cmd = cmd_list[1]
  -- 检查 mason 的 bin 目录
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  local mason_cmd = mason_bin .. "/" .. cmd
  local handle = io.popen("which " .. cmd)
  local result = handle:read("*a")
  handle:close()
  if result ~= "" then
    return true
  end
  -- 检查 mason 目录中的可执行文件
  local f = io.open(mason_cmd, "r")
  if f ~= nil then
    io.close(f)
    -- 将 cmd 替换为 mason 路径
    cmd_list[1] = mason_cmd
    return true
  end
  return false
end

---获取 npm 全局 node_modules 路径
function M.get_global_node_modules()
  local result = vim.fn.system("npm root -g")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local path = vim.trim(result or "")
  if path == "" then
    return nil
  end
  return path
end

---路径是否存在(目录)
function M.path_exists(path)
  return path and vim.fn.isdirectory(path) == 1
end

return M
