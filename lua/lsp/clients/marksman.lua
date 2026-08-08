-- LSP 客户端:marksman(Markdown)
local capabilities = require("lsp.utils").capabilities

return {
  name = "marksman",
  config = {
    capabilities = capabilities,
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = { ".git" },
    single_file_support = true,
  },
}
