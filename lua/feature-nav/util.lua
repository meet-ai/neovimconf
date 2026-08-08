-- feature-nav 纯函数工具(零 vim API / I/O 依赖,可脱离 nvim 测试)
local M = {}

---JSON null → vim.NIL;vim.NIL 在 Lua 中为 truthy,`a or b` 无法从 null 回退到 b
---@param v any
---@param default string|nil
---@return string
function M.json_txt(v, default)
    if v == nil or v == vim.NIL then
        return default or ""
    end
    if type(v) == "string" then
        return v ~= "" and v or (default or "")
    end
    return tostring(v)
end

---左侧列表展示:优先 LLM 名称,否则 GitNexus 的 label 键(如 Clustering)
---@param row table
---@return string
function M.label_row_title(row)
    local s = M.json_txt(row.llm_feature_name, "")
    if s ~= "" then
        return s
    end
    return M.json_txt(row.label, "?")
end

---调 feature-tool 用的 label 主键(GitNexus 类名)
---@param row table
---@return string|nil
function M.label_gitnexus_key(row)
    local k = M.json_txt(row.label, "")
    return k ~= "" and k or nil
end

---JSON 数组:null → 空表;vim.NIL 在 `x or {}` 里会阻断回退,不能用 `#(x or {})` 偷懒
---@param v any
---@return table
function M.json_array(v)
    if v == nil or v == vim.NIL or type(v) ~= "table" then
        return {}
    end
    return v
end

---Process 行展示:有 LLM 名则前置;否则 gitnexus_id / label
---@param p table
---@return string
function M.process_row_title(p)
    local llm = M.json_txt(p.llm_feature_name, "")
    local gid = M.json_txt(p.gitnexus_id, "")
    local theme = M.json_txt(p.gitnexus_label, "")
    local core = nil
    if gid ~= "" then
        local show = gid
        if #show > 24 then
            show = show:sub(1, 21) .. "…"
        end
        --- 流程名与 id 不同则附上,避免只重复 Clustering
        if theme ~= "" and theme ~= gid then
            local t = theme
            if #t > 14 then
                t = t:sub(1, 11) .. "…"
            end
            core = show .. " · " .. t
        else
            core = show
        end
    elseif theme ~= "" then
        core = theme
    else
        core = M.json_txt(p.id, "?")
    end
    if llm ~= "" then
        local short = llm
        if #short > 22 then
            short = short:sub(1, 19) .. "…"
        end
        return short .. " ← " .. core
    end
    if core then
        return core
    end
    return M.json_txt(p.id, "?")
end

---symbol_id 取最后一段作简短名(Function:path:Name → Name)
---@param symbol_id string
---@return string
function M.symbol_id_tail(symbol_id)
    local s = M.json_txt(symbol_id, "")
    if s == "" then
        return "?"
    end
    local tail = s:match("([^:]+)$")
    return tail or s
end

---入口 + process_steps 全量列表(含无路径步,便于对照 DB);仅 jumpable 可预览/Enter
---@param p table
---@return table[]
function M.build_process_chain_locations(p)
    local locs = {}
    local jlist = M.json_array(p.jump_targets)
    local jt = jlist[1]
    if jt and M.json_txt(jt.file_path, "") ~= "" then
        table.insert(locs, {
            tag = "入口",
            file_path = M.json_txt(jt.file_path, ""),
            line_number = tonumber(jt.line_number) or 1,
            jumpable = true,
        })
    end
    local steps = M.json_array(p.steps)
    for i, st in ipairs(steps) do
        local sym = M.symbol_id_tail(M.json_txt(st.symbol_id, ""))
        local fp = M.json_txt(st.file_path, "")
        local ln = tonumber(st.line_number)
        if ln == nil then
            ln = 1
        end
        local tag = string.format("步%d · %s", i, sym)
        if fp ~= "" then
            table.insert(locs, {
                tag = tag,
                file_path = fp,
                line_number = ln,
                jumpable = true,
            })
        else
            table.insert(locs, {
                tag = tag .. " (无路径)",
                file_path = "",
                line_number = ln,
                jumpable = false,
                symbol_id = M.json_txt(st.symbol_id, ""),
            })
        end
    end
    return locs
end

---标签条用的短文案(避免一行过长)
---@param L table
---@param i integer
---@return string
function M.chain_tab_short_label(L, i)
    local tag = M.json_txt(L.tag, "")
    if tag == "入口" then
        return "入"
    end
    local stepn = tag:match("^步(%d+)")
    if stepn then
        return stepn
    end
    if #tag <= 6 then
        return tag
    end
    return tag:sub(1, 5) .. "…"
end

---单行「页面标签」:当前项用 [·] 包起来
---@param locs table[]
---@param current integer
---@param max_cols integer|nil
---@return string
function M.format_chain_tab_bar(locs, current, max_cols)
    max_cols = max_cols or 64
    if #locs == 0 then
        return ""
    end
    local function build(compact)
        local chunks = {}
        for i, L in ipairs(locs) do
            local lab = compact and tostring(i) or M.chain_tab_short_label(L, i)
            if i == current then
                table.insert(chunks, "[" .. lab .. "]")
            else
                table.insert(chunks, lab)
            end
        end
        return " « " .. table.concat(chunks, " ") .. " » "
    end
    local s = build(false)
    if #s > max_cols then
        s = build(true)
    end
    return s
end

---链条列表行(嵌入 / 浮窗头部共用)
---@param locs table[]
---@param idx integer 当前段
---@param tag_w integer
---@return string[]
function M.build_chain_list_lines(locs, idx, tag_w)
    local out = {}
    for i, L in ipairs(locs) do
        local mark = (i == idx) and "▶" or " "
        local fp = L.file_path
        if fp ~= "" and #fp > 56 then
            fp = fp:sub(1, 53) .. "…"
        end
        if fp ~= "" then
            table.insert(
                out,
                string.format("%s %2d. %-" .. tag_w .. "s  %s:%d", mark, i, L.tag, fp, L.line_number)
            )
        else
            table.insert(out, string.format("%s %2d. %s", mark, i, L.tag))
        end
    end
    return out
end

return M
