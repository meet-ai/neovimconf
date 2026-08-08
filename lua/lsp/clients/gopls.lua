-- LSP 客户端:gopls
local capabilities = require("lsp.utils").capabilities

return {
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
}
