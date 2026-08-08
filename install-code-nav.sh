#!/bin/bash

# 代码导航插件安装脚本
# 在 Neovim 中安装和测试代码导航插件

echo "=== 代码导航插件安装脚本 ==="
echo "目标：在 Neovim 中安装代码导航与调用关系可视化相关插件"
echo ""

# 检查 Neovim 配置目录
NVIM_CONFIG="/Users/meetai/source/nvim"
if [ ! -d "$NVIM_CONFIG" ]; then
    echo "错误：Neovim 配置目录不存在: $NVIM_CONFIG"
    exit 1
fi

echo "1. 检查当前插件配置..."
if grep -q "aerial.nvim" "$NVIM_CONFIG/lua/plugins/cursor.lua"; then
    echo "  ✓ aerial.nvim 已配置（大纲）"
else
    echo "  ✗ aerial.nvim 未配置"
fi

if grep -q "callgraph.nvim" "$NVIM_CONFIG/lua/plugins/init.lua"; then
    echo "  ✓ callgraph.nvim 已配置"
else
    echo "  ✗ callgraph.nvim 未配置"
fi

echo ""
echo "2. 安装插件..."
echo "   请打开 Neovim 并运行以下命令："
echo ""
echo "   :Lazy sync"
echo ""
echo "   或者使用快捷键："
echo "   <leader>ps  (如果配置了 which-key)"
echo ""
echo "3. 测试代码导航功能..."
echo ""
echo "   测试文件已创建：test-code-navigation.lua"
echo "   打开测试文件：nvim test-code-navigation.lua"
echo ""
echo "   测试快捷键："
echo "   - <leader>cg : 显示调用关系图（callgraph）"
echo "   - Aerial / Telescope / codemap : 见 lua/core/keymaps.lua 与 lua/codemap.lua"
echo ""
echo "4. 最小配置..."
echo "   最小配置已创建：minimal-code-nav.lua"
echo "   如需单独测试，可以将此配置添加到你的 init.lua"
echo ""
echo "=== 安装完成 ==="
echo ""
echo "下一步："
echo "1. 打开 Neovim 并运行 :Lazy sync"
echo "2. 打开测试文件：nvim test-code-navigation.lua"
echo "3. 使用快捷键测试代码导航功能"
echo "4. 根据需求调整配置"