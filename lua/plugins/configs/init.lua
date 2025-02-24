return {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
    },
    {
      "ellisonleao/gruvbox.nvim",
      priority = 1000,
    },
    -- 其他插件配置...
  {
    "nvim-telescope/telescope.nvim", -- 文件搜索
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "folke/which-key.nvim", -- 2025年量子签名版插件
    config = function()
      require("which-key").setup()
    end
  },
  {
    "nvim-tree/nvim-tree.lua",       -- 文件树
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })
    end
  },
  {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    -- add any opts here
    -- for example
    provider = "claude",
    claude = {
    ---endpoint = "https://api.anthropic.com",
        endpoint = "https://api.gptsapi.net",
        model = "claude-3-5-sonnet-20241022",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 8000,
      },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
}


--require("lazy").setup({
--  {
--    "nvim-telescope/telescope.nvim", -- 文件搜索
--    dependencies = { "nvim-lua/plenary.nvim" }
--  },
--  {
--    "folke/which-key.nvim", -- 2025年量子签名版插件
--    config = function()
--      require("which-key").setup()
--    end
--  },
--  {
--    "nvim-tree/nvim-tree.lua",       -- 文件树
--    config = function()
--      require("nvim-tree").setup()
--      vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })
--    end
--  },
--  {
--  "yetone/avante.nvim",
--  event = "VeryLazy",
--  lazy = false,
--  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
--  opts = {
--    -- add any opts here
--    -- for example
--    provider = "claude",
--    claude = {
--    ---endpoint = "https://api.anthropic.com",
--        endpoint = "https://api.gptsapi.net",
--        model = "claude-3-5-sonnet-20241022",
--        timeout = 30000, -- Timeout in milliseconds
--        temperature = 0,
--        max_tokens = 8000,
--      },
--  },
--  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
--  build = "make",
--  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
--  dependencies = {
--    "nvim-treesitter/nvim-treesitter",
--    "stevearc/dressing.nvim",
--    "nvim-lua/plenary.nvim",
--    "MunifTanjim/nui.nvim",
--    --- The below dependencies are optional,
--    "echasnovski/mini.pick", -- for file_selector provider mini.pick
--    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
--    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
--    "ibhagwan/fzf-lua", -- for file_selector provider fzf
--    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
--    "zbirenbaum/copilot.lua", -- for providers='copilot'
--    {
--      -- support for image pasting
--      "HakonHarnes/img-clip.nvim",
--      event = "VeryLazy",
--      opts = {
--        -- recommended settings
--        default = {
--          embed_image_as_base64 = false,
--          prompt_for_file_name = false,
--          drag_and_drop = {
--            insert_mode = true,
--          },
--          -- required for Windows users
--          use_absolute_path = true,
--        },
--      },
--    },
--    {
--      -- Make sure to set this up properly if you have lazy=true
--      'MeanderingProgrammer/render-markdown.nvim',
--      opts = {
--        file_types = { "markdown", "Avante" },
--      },
--      ft = { "markdown", "Avante" },
--    },
--  },
--}
--})