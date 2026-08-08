-- 模糊搜索:telescope + fzf 扩展
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          -- 让搜索结果显示文件路径
          path_display = { "smart" },
          -- 文件搜索时忽略的目录/模式（减少 Scala 等编译产物干扰）
            file_ignore_patterns = {
              "^%.git/",
              "^node_modules/",
              "^target/",           -- sbt / Scala 编译输出
              "^%.bloop/",          -- Bloop
              "^%.metals/",         -- Metals
              "^%.bsp/",
              "^project/target/",   -- sbt project 编译
              "%.class$",           -- JVM 字节码
              "%.jar$",             -- 如需也排除 jar 可保留
              "%.tasty$",           -- ScalaTest 临时文件
            },
        },
        pickers = {
          find_files = {
            -- 包含隐藏文件，但排除 .git 及编译目录
            hidden = true,
            find_command = {
              "find", ".", "-type", "f",
              "-not", "-path", "*/.git/*",
              "-not", "-path", "*/target/*",
              "-not", "-path", "*/.bloop/*",
              "-not", "-path", "*/.metals/*",
              "-not", "-path", "*/.bsp/*",
              "-not", "-path", "*/node_modules/*",
              "-not", "-name", "*.class",
              "-not", "-name", "*.tasty",
            },
          },
        },
      })
    end,
  },

  -- 更好的搜索界面 (fzf native)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
}
