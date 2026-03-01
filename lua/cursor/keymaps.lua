-- Cursor风格快捷键配置
-- 专为Neovim优化的快捷键系统，避免VSCode风格

local map = vim.keymap.set

-- 初始化Cursor风格快捷键
local function setup_cursor_keymaps()
  -- 使用空格作为Leader键（保持原有习惯）
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  
  -- ===========================================
  -- AI助手快捷键（Cursor核心功能）
  -- ===========================================
  
  -- AI聊天和代码生成
  map("n", "<Leader>ca", function()
    vim.cmd("AvanteChat")
  end, { desc = "Open AI chat" })
  
  -- 对选中文本询问AI
  map("v", "<Leader>ca", ":'<,'>Avante<cr>", { desc = "Ask AI about selection" })
  
  -- AI代码补全触发（插入模式）
  map("i", "<C-x><C-a>", function()
    require("cmp").complete()
  end, { desc = "Trigger AI completion" })
  
  -- ===========================================
  -- 现代化编辑器功能（Cursor特色）
  -- ===========================================
  
  -- 快速打开终端（浮动窗口）
  map("n", "<Leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
  map("t", "<Leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
  
  -- 问题面板（诊断信息）
  map("n", "<Leader>dd", "<cmd>TroubleToggle<cr>", { desc = "Toggle problems" })
  
  -- 代码大纲
  map("n", "<Leader>oo", "<cmd>AerialToggle<cr>", { desc = "Toggle outline" })
  
  -- Git状态切换
  map("n", "<Leader>gg", "<cmd>Gitsigns toggle_signs<cr>", { desc = "Toggle git signs" })
  map("n", "<Leader>gd", function() 
    local ok, gs = pcall(require, "gitsigns")
    if ok then
      gs.diffthis()
    else
      vim.notify("gitsigns not loaded", vim.log.levels.WARN)
    end
  end, { desc = "Git diff current file" })

  map("n", "<Leader>gD", function()
    -- Try telescope git_status first
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok and builtin.git_status then
      builtin.git_status()
    else
      -- Fallback to gitsigns setqflist
      local ok_gs, gs = pcall(require, "gitsigns")
      if ok_gs then
        gs.setqflist("all")
      else
        -- Ultimate fallback: run git diff directly
        local output = vim.fn.system("git diff --name-only")
        if vim.v.shell_error == 0 then
          local lines = vim.split(output, "\n")
          local items = {}
          for _, file in ipairs(lines) do
            if file ~= "" then
              table.insert(items, {filename = file})
            end
          end
          if #items > 0 then
            vim.fn.setqflist({}, ' ', {title = "Git Changes", items = items})
            vim.cmd("copen")
          else
            vim.notify("No changed files", vim.log.levels.INFO)
          end
        else
          vim.notify("Git command failed", vim.log.levels.ERROR)
        end
      end
    end
  end, { desc = "Git diff all files" })
  
  -- 项目切换
  map("n", "<Leader>pp", "<cmd>Telescope projects<cr>", { desc = "Switch project" })
  
  -- ===========================================
  -- 增强搜索功能
  -- ===========================================
  
  -- 智能项目内搜索（包含AI增强）
  map("n", "<Leader>ff", function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin.find_files()
    else
      vim.cmd("Telescope find_files")
    end
  end, { desc = "Find files (smart)" })
  
  -- 实时Grep搜索
  map("n", "<Leader>fg", function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin.live_grep()
    else
      vim.cmd("Telescope live_grep")
    end
  end, { desc = "Live grep in project" })
  
  -- 智能代码搜索（基于语义）
  map("n", "<Leader>fs", function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin.grep_string()
    else
      vim.cmd("Telescope grep_string")
    end
  end, { desc = "Find word under cursor" })
  
  -- ===========================================
  -- 代码智能增强（LSP + AI）
  -- ===========================================
  
  -- AI辅助代码重构
  map("n", "<Leader>lr", function()
    -- 先尝试LSP重命名，然后提供AI建议
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result, ctx, config)
      if err then
        vim.notify("LSP rename failed: " .. tostring(err), vim.log.levels.WARN)
        -- 如果LSP失败，使用AI重命名
        vim.cmd("AvanteChat Rename this symbol to something better: ")
      end
    end)
  end, { desc = "Rename symbol with AI help" })
  
  -- AI代码审查
  map("v", "<Leader>lc", ":'<,'>Avante Please review this code:<cr>", 
    { desc = "AI code review" })
  
  -- AI代码优化
  map("v", "<Leader>lo", ":'<,'>Avante Optimize this code:<cr>", 
    { desc = "AI code optimization" })
  
  -- ===========================================
  -- 工作区管理（Cursor风格）
  -- ===========================================
  
  -- 快速切换工作区
  map("n", "<Leader>ws", function()
    require("telescope").extensions.project.project{} 
  end, { desc = "Switch workspace" })
  
  -- 保存工作区会话
  map("n", "<Leader>wS", function()
    vim.cmd("mksession! .workspace.vim")
    vim.notify("Workspace saved", vim.log.levels.INFO)
  end, { desc = "Save workspace session" })
  
  -- 加载工作区会话
  map("n", "<Leader>wl", function()
    vim.cmd("source .workspace.vim")
    vim.notify("Workspace loaded", vim.log.levels.INFO)
  end, { desc = "Load workspace session" })
  
  -- ===========================================
  -- 协作功能模拟（类似Cursor的协作）
  -- ===========================================
  
  -- 分享代码片段
  map("v", "<Leader>cs", ":'<,'>Avante Create a shareable code snippet for this:<cr>",
    { desc = "Create shareable snippet" })
  
  -- 代码解释
  map("v", "<Leader>ce", ":'<,'>Avante Explain this code:<cr>",
    { desc = "Explain selected code" })
  
  -- 生成文档
  map("v", "<Leader>cd", ":'<,'>Avante Generate documentation for this code:<cr>",
    { desc = "Generate documentation" })
  
  -- ===========================================
  -- 智能辅助功能
  -- ===========================================
  
  -- 自动修复（AI辅助）
  map("n", "<Leader>af", function()
    vim.cmd("AvanteChat Fix any issues in this file:")
  end, { desc = "AI auto-fix" })
  
  -- 代码生成
  map("n", "<Leader>ag", function()
    vim.cmd("AvanteChat Generate code for:")
  end, { desc = "AI code generation" })
  
  -- 测试生成
  map("v", "<Leader>at", ":'<,'>Avante Generate tests for this code:<cr>",
    { desc = "AI test generation" })
  
  -- 调试帮助
  map("v", "<Leader>ad", ":'<,'>Avante Help me debug this code:<cr>",
    { desc = "AI debugging help" })
end

return {
  setup = setup_cursor_keymaps,
}
