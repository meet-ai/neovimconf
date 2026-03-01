# Cursor风格Neovim配置

将你的Neovim改造为类似Cursor编辑器的现代化开发环境。

## 🚀 特性

### 1. AI编程助手
- **Avante.nvim**: 基于DeepSeek的AI聊天和代码生成
- **Codex.nvim**: 类似GitHub Copilot的代码补全
- **快捷键**:
  - `<C-g>`: 切换AI助手
  - `<C-g>` (插入模式): 触发AI补全
  - `<C-g>` (可视模式): 询问选中代码

### 2. VSCode风格快捷键
- **文件操作**: `<C-s>` 保存, `<C-o>` 打开, `<C-n>` 新建
- **编辑操作**: `<C-c>/<C-x>/<C-v>` 复制/剪切/粘贴
- **窗口管理**: `<C-h/j/k/l>` 窗口导航
- **搜索**: `<C-p>` 文件搜索, `<C-f>` 文件内搜索
- **终端**: `<C-\>` 浮动终端

### 3. 现代化UI
- **主题**: tokyonight暗色主题
- **透明背景**: 类似Cursor的视觉风格
- **状态栏**: lualine状态栏
- **文件树**: nvim-tree侧边栏
- **大纲视图**: aerial代码大纲

### 4. 项目管理
- **项目检测**: 自动检测项目根目录
- **项目切换**: `<C-S-p>` 切换项目
- **文件搜索**: 智能项目内搜索

### 5. Git集成
- **Git状态**: 行内Git标记
- **Git操作**: 提交、推送、拉取
- **差异查看**: 内置diff工具

### 6. 开发工具
- **LSP支持**: 全语言服务器支持
- **代码诊断**: 实时错误检查
- **格式化**: 自动代码格式化
- **调试**: 集成调试支持

## 📦 安装的插件

### AI相关
- `yetone/avante.nvim` - AI聊天和代码生成
- `johnseth97/codex.nvim` - GitHub Copilot替代
- `zbirenbaum/copilot.lua` - AI代码补全

### UI增强
- `folke/tokyonight.nvim` - 现代化主题
- `nvim-lualine/lualine.nvim` - 状态栏
- `nvim-tree/nvim-tree.lua` - 文件树
- `stevearc/aerial.nvim` - 代码大纲

### 开发工具
- `lewis6991/gitsigns.nvim` - Git集成
- `akinsho/toggleterm.nvim` - 浮动终端
- `folke/trouble.nvim` - 问题面板
- `numToStr/Comment.nvim` - 智能注释

### 搜索导航
- `nvim-telescope/telescope.nvim` - 模糊搜索
- `ahmedkhalf/project.nvim` - 项目管理

## 🔧 配置结构

```
~/.config/nvim/
├── init.lua              # 主配置文件
├── lua/
│   ├── core/
│   │   ├── bootstrap.lua
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   ├── theme.lua
│   │   └── cursor.lua    # Cursor风格核心
│   ├── cursor/           # Cursor风格模块
│   │   ├── init.lua
│   │   ├── theme.lua
│   │   └── keymaps.lua
│   └── plugins/
│       ├── init.lua
│       ├── configs/
│       └── cursor.lua    # Cursor风格插件
└── README-CURSOR.md
```

## 🎯 使用指南

### 快速开始
1. 打开Neovim: `nvim`
2. 等待插件安装完成
3. 开始使用Cursor风格的Neovim

### 常用快捷键

#### 文件操作
- `<C-s>`: 保存文件
- `<C-o>`: 打开文件
- `<C-p>`: 搜索文件
- `<C-n>`: 新建文件

#### 代码编辑
- `<C-/>`: 注释/取消注释
- `<C-d>`: 复制当前行
- `<F12>`: 跳转到定义
- `<C-.>`: 代码操作

#### AI助手
- `<C-g>`: 切换AI助手面板
- 选中文本 + `<C-g>`: 询问AI
- 插入模式 `<C-g>`: AI补全

#### 窗口管理
- `<C-h/j/k/l>`: 窗口导航
- `<C-w>s/v`: 水平/垂直分割
- `<C-\>`: 切换终端

### 自定义配置

如需自定义配置，可编辑以下文件：
- `lua/cursor/keymaps.lua` - 修改快捷键
- `lua/cursor/theme.lua` - 修改主题
- `lua/plugins/cursor.lua` - 添加/移除插件

## 🔍 故障排除

### 插件安装失败
```bash
# 清理插件缓存
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy
```

### AI功能不工作
1. 检查DeepSeek API密钥是否设置
2. 确保网络连接正常
3. 重启Neovim

### 快捷键冲突
查看当前快捷键映射：
```vim
:map <C-g>
```

## 📚 参考

- [Cursor官网](https://cursor.sh/)
- [Neovim官方文档](https://neovim.io/)
- [Lazy.nvim插件管理器](https://github.com/folke/lazy.nvim)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个配置！

## 📄 许可证

MIT License
