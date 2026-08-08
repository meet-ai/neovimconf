-- 环境/平台适配:登录 shell PATH 继承 + macOS 系统剪贴板
-- 与"编辑器选项"(core/options.lua)分离:这里是环境引导与平台集成

-- GUI/非终端启动时继承登录 shell 的 PATH，使 opencode/npm 等可用
do
  local shell_path_ok, shell_path = pcall(function()
    return vim.fn.system({ vim.o.shell or "zsh", "-i", "-c", "echo -n $PATH" })
  end)
  if shell_path_ok and type(shell_path) == "string" and #shell_path > 0 then
    vim.env.PATH = shell_path .. ":" .. (vim.env.PATH or "")
  end
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
end
