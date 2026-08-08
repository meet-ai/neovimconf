-- LSP 客户端:metals(Scala)
local capabilities = require("lsp.utils").capabilities

return {
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
}
