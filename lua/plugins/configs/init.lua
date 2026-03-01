--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2025-04-11 20:45:35
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2025-04-12 08:14:37
FilePath: /nvim/lua/plugins/configs/init.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
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
}


