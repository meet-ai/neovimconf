local M = {}

M.setup = function()
  local avante = require("avante")
  
  -- 配置 avante 补全
  avante.setup({
    -- 设置补全触发字符
    trigger_characters = { ".", ":", "->", "=>", "@", "#", "$", "%", "&", "*", "+", "-", "/", "<", "=", ">", "?", "^", "|", "~" },
    
    -- 设置补全优先级
    priority = {
      lsp = 1000,
      avante = 900,
      buffer = 800,
      path = 700,
    },
    
    -- 设置补全过滤
    filter = {
      min_length = 2,  -- 最小补全长度
      max_length = 50, -- 最大补全长度
    },
    
    -- 设置补全排序
    sort = {
      -- 按相关性排序
      by = "relevance",
      -- 设置权重
      weights = {
        prefix = 0.8,
        suffix = 0.2,
        exact = 1.0,
        fuzzy = 0.7,
      },
    },
    
    -- 设置补全预览
    preview = {
      enabled = true,
      delay = 100,  -- 预览延迟（毫秒）
    },
    
    -- 设置补全文档
    documentation = {
      enabled = true,
      format = "markdown",
    },
  })
end

return M 