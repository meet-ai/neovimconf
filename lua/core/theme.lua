-- 主题配置:加载 desert + 透明背景 + ThemeToggle(注册表驱动)
vim.opt.termguicolors = true  -- 启用真彩色支持

-- 设置透明背景
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

-- 加载 desert 主题（内置 :h default-colors）
local function load_theme()
  vim.o.background = "dark"
  vim.cmd('colorscheme desert')
  vim.notify("使用 desert 主题", vim.log.levels.INFO)
  return true
end

-- 加载主题
load_theme()

-- 主题注册表:name 用于匹配当前主题;require_name 用于可用性探测(nil=内置主题)
-- 切换时非 tokyonight 主题翻转 background;tokyonight 按 background 选 variant(与原始行为一致)
local themes = {
  { name = "desert" },
  {
    name = "tokyonight",
    require_name = "tokyonight",
    apply = function()
      local variant = vim.o.background == "light" and "tokyonight-day" or "tokyonight-night"
      vim.cmd('colorscheme ' .. variant)
    end,
  },
  { name = "gruvbox", require_name = "gruvbox" },
}

-- 添加主题切换命令
vim.api.nvim_create_user_command('ThemeToggle', function()
  local current = vim.g.colors_name or ''
  local idx = 1
  for i, t in ipairs(themes) do
    if current:find(t.name, 1, true) then
      idx = i
      break
    end
  end
  -- 从下一个主题开始，找到第一个可用的
  for step = 1, #themes do
    local t = themes[(idx + step - 1) % #themes + 1]
    local available = t.require_name == nil or pcall(require, t.require_name)
    if available then
      if t.name ~= "tokyonight" then
        vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
      end
      if t.apply then
        t.apply()
      else
        vim.cmd('colorscheme ' .. t.name)
      end
      -- 重新应用 cursor 主题高亮覆盖
      local cursor_theme_ok, cursor_theme = pcall(require, "cursor.theme")
      if cursor_theme_ok and cursor_theme.setup then
        cursor_theme.setup()
      end
      vim.notify("切换到主题: " .. (vim.g.colors_name or 'unknown'), vim.log.levels.INFO)
      return
    end
  end
  vim.notify("没有可用主题", vim.log.levels.WARN)
end, {})
