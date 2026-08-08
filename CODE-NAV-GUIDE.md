# Neovim 代码导航最小体验指南

## 概述
这个指南帮助你快速体验在 Neovim 中的代码导航功能，包括代码地图、大纲和调用关系可视化。

## 已创建的文件
1. `test-code-navigation.lua` - 测试代码文件
2. `minimal-code-nav.lua` - 最小配置
3. `install-code-nav.sh` - 安装脚本
4. `CODE-NAV-GUIDE.md` - 本指南

## 快速开始

### 1. 检查当前配置
你的 Neovim 配置已经包含了代码导航插件配置（在 `lua/plugins/init.lua` 中）。

运行检查脚本：
```bash
chmod +x install-code-nav.sh
./install-code-nav.sh
```

### 2. 安装插件
打开 Neovim 并运行：
```vim
:Lazy sync
```
或者使用快捷键（如果配置了 which-key）：
- `<leader>ps`

### 3. 测试代码导航功能

#### 打开测试文件
```bash
nvim test-code-navigation.lua
```

#### 快捷键指南

##### 代码地图 (neominimap)
- `<leader>mm` - 切换代码地图 (`:Neominimap Toggle`)
- `<leader>mf` - 聚焦代码地图 (`:Neominimap ToggleFocus`)

**功能特点**：
- 显示文件的缩略图
- 高亮显示当前光标位置
- 显示诊断信息（错误、警告）
- 显示 Git 变更
- 跟随光标滚动

##### 代码大纲 (outline.nvim)
- `<leader>oo` - 打开代码大纲
- `<leader>oc` - 关闭大纲
- `<leader>ot` - 切换大纲

**功能特点**：
- 显示文件结构（函数、类、变量）
- 支持符号折叠
- 预览窗口
- 显示符号详情

##### 调用关系可视化 (callgraph.nvim)
- `<leader>cg` - 显示调用关系图
- `<leader>ce` - 导出调用图

**功能特点**：
- 显示函数调用关系
- 支持深度限制
- 可导出为图形文件

## 使用场景示例

### 场景1：理解代码结构
1. 打开一个复杂文件
2. 按 `<leader>oo` 打开大纲
3. 浏览文件结构，快速跳转到感兴趣的函数

### 场景2：代码导航
1. 在大型文件中浏览
2. 按 `<leader>mm` 打开代码地图
3. 在地图中点击位置快速跳转

### 场景3：分析调用关系
1. 光标放在函数名上
2. 按 `<leader>cg` 查看调用关系
3. 分析函数的调用者和被调用者

## 配置说明

### 已配置的插件
你的 `lua/plugins/init.lua` 已经包含了以下配置：

```lua
-- 代码地图可视化
{
  "Isrothy/neominimap.nvim",
  config = function()
    require("neominimap").setup({
      auto_enable = true,
      layout = "float",
      width = 0.35,
      height = 0.7,
      follow_cursor = true,
    })
  end,
  keys = {
    { "<leader>mm", "<cmd>NeominimapToggle<cr>", desc = "Toggle Code Map" },
  }
},

-- 代码大纲
{
  "hedyhli/outline.nvim",
  config = function()
    require("outline").setup({
      position = "right",
      width = 40,
      preview_window = true,
    })
  end,
  keys = {
    { "<leader>oo", "<cmd>Outline<cr>", desc = "Open Code Outline" },
  }
},

-- 调用关系可视化
{
  "barreiroleo/callgraph.nvim",
  config = function()
    require("callgraph").setup({
      run = { direction = "mix" },
    })
  end,
  keys = {
    { "<leader>cg", function() require("callgraph").run() end, desc = "Show Call Graph" },
  }
}
```

### 自定义配置
如果需要调整配置，可以修改：
1. `lua/plugins/init.lua` 中的插件配置
2. 或者使用 `minimal-code-nav.lua` 中的配置

## 故障排除

### 插件未安装
如果插件没有安装，运行：
```vim
:Lazy clean
:Lazy sync
```

### 快捷键无效
检查 `lua/core/keymaps.lua` 中是否有冲突的快捷键配置。

### 功能不正常
1. 确保 Treesitter 已安装：
   ```vim
   :TSInstall lua
   ```
2. 检查 LSP 是否正常工作

## 下一步

### 集成 GitNexus
要集成 GitNexus 进行智能代码导读，需要：
1. 启动 GitNexus MCP 服务器
2. 配置 GitNexus 与 Neovim 的集成
3. 创建自定义代码导读工作流

### 高级功能
1. 自定义代码地图样式
2. 添加更多代码分析工具
3. 集成 OpenCode 进行 AI 辅助代码导读

## 支持的语言
- Lua (测试文件使用)
- JavaScript/TypeScript
- Python
- Java
- Go
- Rust
- 其他支持 Treesitter 的语言

## 反馈
如果在使用过程中遇到问题或有改进建议，请记录在 `test-code-navigation.lua` 文件的注释中。