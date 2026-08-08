# cursor-agent.nvim 调研

## 作用

在 Neovim 内通过**浮动终端**运行 **Cursor Agent CLI**，不离开编辑器即可用 AI 对话、发当前文件/选区到 Agent。

## 方案对比

| 仓库 | Stars | 特点 |
|------|-------|------|
| **xTacobaco/cursor-agent.nvim** | ~54 | 极简、文档全、仅浮动终端 + 发选区/缓冲区 |
| Sarctiann/cursor-agent.nvim | ~7 | 多窗口/会话/snacks.nvim，文档少 |

**推荐**：使用 **xTacobaco/cursor-agent.nvim**。

## 前置条件

- Neovim ≥ 0.9
- **Cursor Agent CLI** 已安装且在 `$PATH` 中可执行（命令名一般为 `cursor-agent`）

若未安装：在 Cursor 里通过 Command Palette 安装/启用 “Cursor Agent CLI”，或查官方文档确保 `cursor-agent` 在终端可用。

## 命令与快捷键（已配置）

- `:CursorAgent` — 打开/关闭浮动终端（项目根目录）
- `:CursorAgentSelection` — 把当前**可视选区**发给 Agent（会写临时文件并打开终端）
- `:CursorAgentBuffer` — 把**当前整个 buffer** 发给 Agent

建议快捷键（已在 `plugins/cursor.lua` 中配置）：

- `<Leader>ca` 普通模式：打开/关闭 Cursor Agent 终端
- `<Leader>ca` 可视模式：发送选区
- `<Leader>cA` 普通模式：发送当前 buffer

终端内：`q`（normal 模式）或再次 `:CursorAgent` 关闭浮动终端。

## 易错点

1. **找不到 CLI**：终端执行 `which cursor-agent`，若没有则需先安装并保证在 PATH 中。
2. **工作目录**：终端在「项目根」启动（优先 LSP root，否则用 `.git` 等常见标记）。
3. **选区/缓冲区**：Selection/Buffer 会先写入临时文件，再把文件路径作为参数传给 CLI。

## 配置位置

- 插件与 keymap：`lua/plugins/cursor.lua`
- 可选 `setup` 参数（如自定义 `cmd`/`args`）：同上文件内 `require("cursor-agent").setup({ ... })`
