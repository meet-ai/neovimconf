-- LSP 全家:Mason 安装器 + LSP 服务器配置
return {
  -- Mason 插件管理器
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        -- 仅填 mason-registry 里存在的 lspconfig 名
        ensure_installed = {
          "jdtls",
          "gopls",
          "pyright",
          "ts_ls", -- 原 tsserver，与 nvim-lspconfig / mason-lspconfig 命名一致
          "rust_analyzer",
          "clangd",
          "marksman", -- Markdown LSP
        },
      })
    end,
  },

  -- LSP 相关插件
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("lsp.init")
    end,
  },
}
