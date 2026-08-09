-- LSP 装配入口:capabilities、日志抑制、LspAttach 键位/格式化、服务器启动
-- 客户端配置在 lsp/clients/*.lua;工具在 lsp/utils.lua;UI 在 lsp/ui.lua
local utils = require("lsp.utils")
local capabilities = utils.capabilities

-- 设置 LSP 日志级别（静默模式）；vim.lsp.set_log_level 已弃用
vim.lsp.log.set_level(vim.log.levels.OFF)

-- 自定义 LSP 处理器，抑制 info 级别的日志消息
vim.lsp.handlers["window/logMessage"] = function(err, method, params, client_id)
  if params.type and (params.type == 1 or params.type == 2) then
    -- 只显示 error (1) 和 warning (2)
    vim.notify(params.message, params.type)
  end
  -- 否则忽略 info (3) 和 log (4) 消息
end

-- 抑制 info 级别的 showMessage 通知
vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
  if params.type and (params.type == 1 or params.type == 2) then
    -- 只显示 error (1) 和 warning (2)
    vim.notify(params.message, params.type)
  end
  -- 否则忽略 info (3) 和 log (4) 消息
end

-- 忽略进度通知
vim.lsp.handlers["$/progress"] = function() end

-- LSP 客户端附加回调（使用 Neovim 0.11 推荐的 LspAttach 事件）
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf
    if not client then
      return
    end

    -- 在附加的 buffer 上设置 LSP 键位，避免被 GUI 全局快捷键拦截（如 g 被 Go 菜单占用）
    local function buf_map(mode, lhs, rhs, opts)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = bufnr }))
    end
    buf_map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    buf_map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
    buf_map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
    buf_map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
    -- GUI 下若 "g" 被应用占用，可用 Ctrl+] 跳定义
    if vim.fn.has("gui_running") == 1 then
      buf_map("n", "<C-]>", vim.lsp.buf.definition, { desc = "Go to definition (GUI fallback)" })
    end

    -- 按语言启用保存时格式化
    local ft = vim.bo[bufnr].filetype
    local format_fts = { ["go"] = true, ["java"] = true, ["kotlin"] = true }
    if format_fts[ft] then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- 服务器列表:静态客户端 + angularls 工厂
local servers = {}
for _, client_mod in ipairs({
  "lsp.clients.gopls",
  "lsp.clients.jdtls",
  "lsp.clients.marksman",
}) do
  local ok, client = pcall(require, client_mod)
  if ok and client then
    table.insert(servers, client)
  end
end

local make_angularls = require("lsp.clients.angularls")
local angular_server = make_angularls()
if angular_server then
  table.insert(servers, angular_server)
end

-- 启动 LSP 服务器（使用 vim.lsp.config + vim.lsp.enable）
for _, server in ipairs(servers) do
  if utils.check_server_availability(server.config.cmd) then
    local success, err = pcall(function()
      vim.lsp.config(server.name, server.config)
      vim.lsp.enable(server.name)
    end)
    if not success then
      vim.notify("Error setting up " .. server.name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- 设置 LSP 快捷键（gd/gr/gi/K 已在 LspAttach 中按 buffer 设置，此处只保留全局用到的）
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format code" })

-- 诊断显示与图标
require("lsp.ui")
