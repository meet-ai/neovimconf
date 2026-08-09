-- pi.nvim 键位（Doom 风格：Leader=,）
-- 注意：不用 <Leader>pi —— 你的配置里 <Leader>p 是粘贴，timeoutlen=500ms 下按不快会触发粘贴。
-- 用空闲的 ,a 前缀（,aa 已被 opencode 占用，但 ,ai/,am/,at 空闲）。
local map = require("core.keymaps.util").map

map("n", "<Leader>ai", function() require("pi").toggle() end, { desc = "pi: toggle float" })
map("n", "<Leader>am", function() require("pi").cycle_model() end, { desc = "pi: cycle model" })
map("n", "<Leader>at", function() require("pi").cycle_thinking_level() end, { desc = "pi: cycle thinking" })
