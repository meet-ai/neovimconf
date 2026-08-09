-- pi.neovim 键位（Doom 风格：Leader=,）
-- 只用 ,ai 开关（原生 pi TUI float）；模型/思考级别在 pi TUI 内部用 / 命令切换
local map = require("core.keymaps.util").map

map("n", "<Leader>ai", function() require("pi").toggle() end, { desc = "pi: toggle TUI float" })
