local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

    -- 设置自动命令来显示诊断信息（静默）
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        local diagnostics = vim.diagnostic.get(bufnr)
        if #diagnostics > 0 then
          -- 静默模式：不打印
        end
      end,
    })

    -- 按语言启用保存时格式化
    local ft = vim.bo[bufnr].filetype
    if ft == "go" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    elseif ft == "java" or ft == "kotlin" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    elseif ft == "scala" or ft == "sbt" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- 检查 LSP 服务器是否可用（静默模式）
local function check_server_availability(cmd_list)
  if not cmd_list or not cmd_list[1] then
    return false
  end
  local cmd = cmd_list[1]
  -- 检查 mason 的 bin 目录
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  local mason_cmd = mason_bin .. "/" .. cmd
  local handle = io.popen("which " .. cmd)
  local result = handle:read("*a")
  handle:close()
  if result ~= "" then
    return true
  end
  -- 检查 mason 目录中的可执行文件
  local f = io.open(mason_cmd, "r")
  if f ~= nil then
    io.close(f)
    -- 将 cmd 替换为 mason 路径
    cmd_list[1] = mason_cmd
    return true
  end
  return false
end

local function get_global_node_modules()
  local result = vim.fn.system("npm root -g")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local path = vim.trim(result or "")
  if path == "" then
    return nil
  end
  return path
end

local function path_exists(path)
  return path and vim.fn.isdirectory(path) == 1
end

local function make_angularls_server()
  local global_node_modules = get_global_node_modules()
  local ngserver_cmd = { "ngserver", "--stdio" }
  if not check_server_availability(ngserver_cmd) then
    return nil
  end

  local global_probe_locations = {}
  if global_node_modules then
    table.insert(global_probe_locations, global_node_modules)
  end

  return {
    name = "angularls",
    config = {
      capabilities = capabilities,
      cmd = ngserver_cmd,
      filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
      root_markers = { "angular.json", "project.json", "nx.json" },
      on_new_config = function(new_config, root_dir)
        local ts_probe_locations = {}
        local ng_probe_locations = {}
        local project_node_modules = root_dir and (root_dir .. "/node_modules") or nil

        if path_exists(project_node_modules) then
          table.insert(ts_probe_locations, project_node_modules)
          local project_angular_node_modules = project_node_modules .. "/@angular/language-server/node_modules"
          if path_exists(project_angular_node_modules) then
            table.insert(ng_probe_locations, project_angular_node_modules)
          end
        end

        for _, p in ipairs(global_probe_locations) do
          table.insert(ts_probe_locations, p)
          local global_angular_node_modules = p .. "/@angular/language-server/node_modules"
          if path_exists(global_angular_node_modules) then
            table.insert(ng_probe_locations, global_angular_node_modules)
          end
        end

        local cmd = { ngserver_cmd[1], ngserver_cmd[2] }
        if #ts_probe_locations > 0 then
          vim.list_extend(cmd, { "--tsProbeLocations", table.concat(ts_probe_locations, ",") })
        end
        if #ng_probe_locations > 0 then
          vim.list_extend(cmd, { "--ngProbeLocations", table.concat(ng_probe_locations, ",") })
        end
        vim.list_extend(cmd, { "--angularCoreVersion", "" })
        new_config.cmd = cmd
      end,
    },
  }
end

-- 使用 vim.lsp.config (Neovim 0.11+) 配置 LSP 服务器，替代已废弃的 require('lspconfig')
local servers = {
  {
    name = "gopls",
    config = {
      capabilities = capabilities,
      cmd = { "gopls", "serve" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_markers = { "go.mod", ".git" },
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
          gofumpt = true,
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
            tidy = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          verboseOutput = false,
        },
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        trace = "off",
      },
    },
  },
  {
    name = "jdtls",
    config = {
      capabilities = capabilities,
      cmd = { "jdtls" },
      filetypes = { "java", "kotlin" },
      root_markers = {
        "pom.xml",
        "gradle.build",
        "gradle.build.kts",
        "build.gradle",
        "build.gradle.kts",
        ".git",
      },
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.junit.jupiter.api.Assertions.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
          configuration = {
            runtimes = {
              {
                name = "JavaSE-17",
                path = "/Users/meetai/.sdkman/candidates/java/17.0.14-tem",
                default = true,
              },
              {
                name = "JavaSE-21",
                path = "/Users/meetai/.sdkman/candidates/java/21.0.6-graal",
                default = true,
      },
      init_options = {
        trace = "off",
      },
    },
          },
          format = {
            settings = {
              url = vim.fn.expand("~/.config/nvim/lua/lsp/eclipse-java-google-style.xml"),
              profile = "GoogleStyle",
            },
          },
        },
      },
    },
  },
  {
    name = "metals",
    config = {
      capabilities = capabilities,
      cmd = { "metals" },
      filetypes = { "scala", "sbt" },
      root_markers = {
        "build.sbt",
        "build.sc",
        "build.scala",
        "build.mill",
        ".mill-version",
        "mill-version",
        "project/build.properties",
        ".git",
      },
      settings = {
        metals = {
          enable = true,
          serverVersion = "latest.release",
          showImplicitArguments = true,
          showInferredType = true,
          superMethodLensesEnabled = true,
          trace = "off",
        },
      },
    },
  },
  {
    name = "marksman",
    config = {
      capabilities = capabilities,
      cmd = { "marksman", "server" },
      filetypes = { "markdown" },
      root_markers = { ".git" },
      single_file_support = true,
    },
  },
}

local angular_server = make_angularls_server()
if angular_server then
  table.insert(servers, angular_server)
end

-- 启动 LSP 服务器（使用 vim.lsp.config + vim.lsp.enable）
for _, server in ipairs(servers) do
  if check_server_availability(server.config.cmd) then
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

-- 设置 LSP 诊断
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

-- 设置 LSP 图标
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
