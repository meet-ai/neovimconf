local opt = vim.opt

-- 视觉设置
opt.number = true         -- 行号
opt.relativenumber = true -- 相对行号
opt.cursorline = true     -- 高亮当前行
opt.signcolumn = "yes"    -- 始终显示标记列

-- 编辑设置
opt.expandtab = true      -- 空格替代Tab
opt.tabstop = 4           -- Tab宽度
opt.shiftwidth = 4        -- 自动缩进宽度
opt.smartindent = true    -- 智能缩进

-- 搜索设置
opt.ignorecase = true     -- 忽略大小写
opt.smartcase = true      -- 智能大小写匹配
