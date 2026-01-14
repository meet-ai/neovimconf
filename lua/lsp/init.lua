local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 设置 LSP 日志级别
vim.lsp.set_log_level("debug")

-- 打印 LSP 客户端信息
local function on_attach(client, bufnr)
  print("LSP attached to buffer " .. bufnr)
  print("Client name: " .. client.name)
  print("Client capabilities: " .. vim.inspect(client.server_capabilities))
  
  -- 设置自动命令来显示诊断信息
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local diagnostics = vim.diagnostic.get(bufnr)
      if #diagnostics > 0 then
        --print("Diagnostics for buffer " .. bufnr .. ": " .. vim.inspect(diagnostics))
      end
    end,
  })
end

-- 检查 LSP 服务器是否可用
local function check_server_availability(server)
  local cmd = server.cmd[1]
  print("Checking server availability for: " .. cmd)
  local handle = io.popen("which " .. cmd)
  local result = handle:read("*a")
  handle:close()
  print("Server " .. cmd .. " found: " .. tostring(result ~= ""))
  return result ~= ""
end

-- 设置 LSP 服务器
local servers = {
  {
    name = "gopls",
    config = {
      capabilities = capabilities,
      cmd = { "gopls", "serve" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
      on_attach = function(client, bufnr)
        print("gopls on_attach called")
        on_attach(client, bufnr)
        -- 启用文档格式化
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
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
        },
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
      },
    }
  },
  {
    name = "jdtls",
    config = {
      capabilities = capabilities,
      cmd = { "jdtls" },
      filetypes = { "java", "kotlin" },
      root_dir = lspconfig.util.root_pattern(
        "pom.xml",
        "gradle.build",
        "gradle.build.kts",
        "build.gradle",
        "build.gradle.kts",
        ".git"
      ),
      on_attach = function(client, bufnr)
        print("jdtls on_attach called")
        on_attach(client, bufnr)
        -- 启用文档格式化
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = { "*.java", "*.kt", "*.kts" },
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
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
    }
  },
  -- 其他服务器配置...
}

-- 启动 LSP 服务器
print("Starting LSP servers...")
for _, server in ipairs(servers) do
  print("Processing server: " .. server.name)
  if check_server_availability(server.config) then
    print("Setting up LSP server: " .. server.name)
    local success, err = pcall(function()
      lspconfig[server.name].setup(server.config)
    end)
    if not success then
      print("Error setting up " .. server.name .. ": " .. tostring(err))
    else
      print("Successfully set up " .. server.name)
    end
  else
    print("Warning: LSP server " .. server.name .. " not found in PATH")
  end
end

-- 设置 LSP 快捷键
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
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

-- 打印当前活动的 LSP 客户端
print("Active LSP clients: " .. vim.inspect(vim.lsp.get_active_clients()))
