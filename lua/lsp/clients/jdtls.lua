-- LSP 客户端:jdtls(Java/Kotlin)
-- ⚠️ 本机配置:configuration.runtimes 的 JDK 路径是作者机器的 SDKMAN 路径,
-- 换机器时修改下面 jdtls_jdk_* 变量即可。
local capabilities = require("lsp.utils").capabilities

-- 本机 JDK 路径(SDKMAN)
local JDK17 = "/Users/meetai/.sdkman/candidates/java/17.0.14-tem"
local JDK21 = "/Users/meetai/.sdkman/candidates/java/21.0.6-graal"

-- 格式化样式文件(仓库内)
local eclipse_style_xml = vim.fn.expand("~/.config/nvim/lua/lsp/eclipse-java-google-style.xml")

return {
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
              path = JDK17,
              default = true,
            },
            {
              name = "JavaSE-21",
              path = JDK21,
              default = true,
            },
          },
        },
        format = {
          settings = {
            url = eclipse_style_xml,
            profile = "GoogleStyle",
          },
        },
      },
    },
    init_options = {
      trace = "off",
    },
  },
}
