-- feature-nav 配置常量
local M = {}

M.tool_path = os.getenv("HOME") .. "/.agents/skills/feature-nav/scripts/feature-tool.js"

---左侧列表宽度占整列比例
M.left_width_ratio = 0.32
---右侧上半部分高度占整列高度的比例(余下为代码区)
M.preview_top_ratio = 0.44
---上半行内「详情」宽度占右侧总宽的比例
M.detail_in_right_ratio = 0.52
---代码预览:目标行上下各显示行数
M.code_context_lines = 14
---浮窗预览:更大上下文
M.popout_context_lines = 28
---嵌入的「代码预览」窗:false 时只列链条(入口/步 + 路径),不 read_file;看代码用 P 浮窗
M.embed_show_code_snippet = false
---仅列链条时 tag 列宽(字符)
M.embed_chain_tag_width = 32

return M
