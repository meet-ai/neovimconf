local luasnip = require('luasnip')

-- 加载代码片段
require('luasnip.loaders.from_vscode').lazy_load()

-- 自定义代码片段
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

luasnip.add_snippets('java', {
  s('main', {
    t('public static void main(String[] args) {'),
    t({ '', '    ' }),
    i(1),
    t({ '', '}' }),
  }),
  s('class', {
    t('public class '),
    i(1),
    t(' {'),
    t({ '', '    ' }),
    i(2),
    t({ '', '}' }),
  }),
  s('for', {
    t('for (int '),
    i(1, 'i'),
    t(' = '),
    i(2, '0'),
    t('; '),
    i(1),
    t(' < '),
    i(3),
    t('; '),
    i(1),
    t('++) {'),
    t({ '', '    ' }),
    i(4),
    t({ '', '}' }),
  }),
}) 