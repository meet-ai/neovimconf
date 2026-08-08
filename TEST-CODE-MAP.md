# 🗺️ 代码地图导航系统测试指南

## 🎯 系统概述
这是一个类似**高德地图**的代码导航系统，不是简单的 minimap 缩略图。它提供：
1. **全局代码结构视图** - 类似地图的代码概览
2. **调用关系分析** - 显示代码执行路径
3. **智能代码导读** - 从功能特性出发分析代码
4. **完全 Neovim 集成** - 在编辑器内部使用

## 🚀 快速开始

### 1. 重新加载配置
```bash
cd /Users/meetai/source/nvim
nvim
# 在 Neovim 中运行：
:source $MYVIMRC
```

### 2. 测试核心功能

#### 🗺️ **代码地图视图**
```
<leader>cm  # 打开代码地图（主快捷键）
:CodeMap    # 命令行方式
```

**预期效果**：
- 右侧显示代码结构树（符号树）
- 类似文件浏览器的树状结构
- 可以展开/折叠节点
- 点击节点快速跳转

#### 🔗 **调用关系分析**
```
<leader>cc  # 打开调用树
:CallTree   # 命令行方式
```

**预期效果**：
- 显示函数调用关系
- 树状或图形化展示
- 分析代码执行路径

#### 📋 **代码导航面板**
```
<leader>cn  # 打开导航面板
:CodeNav    # 命令行方式
```

**预期效果**：
- 综合导航面板
- 包含符号、引用、诊断等信息
- 一站式代码导航

### 3. 详细测试流程

#### 测试文件准备
```bash
# 打开测试文件
nvim test-code-navigation.lua
```

#### 测试步骤
1. **打开代码地图**：按 `<leader>cm`
   - 观察右侧是否显示代码结构
   - 尝试展开/折叠节点
   - 点击节点跳转

2. **分析调用关系**：
   - 将光标放在 `authenticate` 函数上
   - 按 `<leader>cc` 查看调用关系

3. **使用导航功能**：
   - 按 `gd` 跳转到定义
   - 按 `gr` 查找引用
   - 按 `<leader>ca` 查看代码操作

4. **功能特性分析**：
   ```
   :CodeAnalyze authenticate
   ```
   - 分析 `authenticate` 功能相关代码

## 🛠️ 功能对比

| 功能 | neominimap (错误) | navigator.lua (正确) |
|------|------------------|---------------------|
| **全局视图** | 文件缩略图 | 代码结构树 |
| **导航体验** | 缩略图点击 | 树状导航+跳转 |
| **调用关系** | 无 | 完整的调用树 |
| **功能分析** | 无 | 支持功能特性分析 |
| **集成度** | 简单插件 | 完整导航系统 |

## 🔧 配置说明

### 已配置的核心组件
1. **navigator.lua** - 主导航引擎（已安装并配置）
2. **代码地图模块** - `lua/codemap.lua`（新增）
3. **快捷键系统** - 统一的快捷键映射

### 快捷键映射
```
<leader>cm - 打开代码地图
<leader>cs - 切换符号树
<leader>cc - 切换调用树
<leader>cd - 切换诊断面板
<leader>cn - 打开导航面板

gd - 跳转到定义
gr - 查找引用
gi - 跳转到实现
gt - 跳转到类型定义
```

### 命令系统
```
:CodeMap     - 打开代码地图
:CallTree    - 打开调用树  
:CodeNav     - 打开导航面板
:CodeAnalyze - 分析代码功能
```

## 🧪 测试用例

### 用例1：代码结构导航
1. 打开 `test-code-navigation.lua`
2. 按 `<leader>cm`
3. 在代码地图中浏览结构
4. 点击 `UserAuthService:authenticate` 跳转

### 用例2：调用关系分析
1. 光标放在 `registerUser` 函数
2. 按 `<leader>cc`
3. 分析该函数的调用关系

### 用例3：功能特性分析
1. 运行 `:CodeAnalyze authentication`
2. 查看所有认证相关代码
3. 在 quickfix 列表中跳转

## 🔍 故障排除

### 问题1：快捷键无效
```vim
" 检查快捷键映射
:map <leader>cm
:WhichKey <leader>c

" 手动加载模块
:lua require('codemap').setup()
```

### 问题2：navigator.lua 未加载
```vim
" 检查插件状态
:Lazy load navigator.lua
:checkhealth navigator

" 检查 LSP 状态
:LspInfo
```

### 问题3：代码地图不显示
```vim
" 检查符号树
:lua require('navigator.sidepanel').toggle('symbols')

" 检查 LSP 符号
:lua vim.lsp.buf_request(0, 'textDocument/documentSymbol', {}, print)
```

## 📊 性能测试

### 测试大型文件
```bash
# 创建一个大型测试文件
for i in {1..1000}; do echo "function test_$i() return $i end" >> large-test.lua; done

# 测试性能
nvim large-test.lua
<leader>cm  # 观察加载速度
```

### 内存使用
```vim
" 检查内存使用
:lua print(collectgarbage("count") .. " KB")
```

## 🎨 自定义配置

如果需要调整配置，修改以下文件：

1. **导航器配置**：`lua/plugins/init.lua` 第75-105行
2. **代码地图模块**：`lua/codemap.lua`
3. **快捷键**：`lua/codemap.lua` 第25-50行

## ✅ 验收标准

代码地图导航系统成功的标志：

- [ ] `<leader>cm` 能打开代码结构树
- [ ] 代码地图支持展开/折叠节点
- [ ] 点击节点能正确跳转
- [ ] `<leader>cc` 能显示调用关系
- [ ] `:CodeAnalyze` 能分析功能特性
- [ ] 导航响应迅速，无明显延迟
- [ ] 与现有 Neovim 功能无冲突

## 📈 下一步优化

1. **集成 GitNexus** - 添加智能代码分析
2. **图形化视图** - 添加图形化调用图
3. **缓存机制** - 提高大型项目性能
4. **自定义视图** - 支持用户自定义地图样式

---

**现在开始测试吧！先从 `<leader>cm` 开始，体验真正的代码地图导航。**