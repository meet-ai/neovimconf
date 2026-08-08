-- feature-nav GitNexus CLI 客户端:同步调用 feature-tool.js + 数据加载
local config = require("feature-nav.config")

local M = {}

---当前项目名(cwd 的 basename)
---@return string
function M.get_project_name()
    local cwd = vim.fn.getcwd()
    local real_path = vim.fn.resolve(cwd)
    local project_name = real_path:match("([^/]+)$")
    return project_name or "default"
end

---@param argv string[]
function M.run_tool(argv)
    local parts = { "node", config.tool_path, "--repo", M.get_project_name() }
    vim.list_extend(parts, argv)
    local shell = {}
    for _, p in ipairs(parts) do
        table.insert(shell, vim.fn.shellescape(p))
    end
    local output = vim.fn.system(table.concat(shell, " "))
    local ok, result = pcall(vim.fn.json_decode, output)
    if ok then
        return result
    end
    return { status = "error", message = output }
end

---解析 workspace 路径(相对 repo_root 或 cwd)
function M.resolve_workspace_path(p)
    if not p or p == "" then
        return nil
    end
    if vim.fn.filereadable(p) == 1 then
        return vim.fn.fnamemodify(p, ":p")
    end
    local root = M.state_repo_root or vim.fn.getcwd()
    local joined = vim.fs.joinpath(root, p)
    if vim.fn.filereadable(joined) == 1 then
        return vim.fn.fnamemodify(joined, ":p")
    end
    local trimmed = p:gsub("^%./", "")
    joined = vim.fs.joinpath(root, trimmed)
    if vim.fn.filereadable(joined) == 1 then
        return vim.fn.fnamemodify(joined, ":p")
    end
    return nil
end

---@param path string
---@param center_line integer
---@param ctx integer
---@return string[]|nil lines
---@return string|nil resolved_path
---@return integer|nil mark_buf_line 预览缓冲区内「目标行」的 1-based 行号(供 zz 居中)
function M.read_code_snippet(path, center_line, ctx)
    local full = M.resolve_workspace_path(path)
    if not full or vim.fn.filereadable(full) ~= 1 then
        return nil, nil, nil
    end
    local lines = vim.fn.readfile(full)
    if not lines or #lines == 0 then
        return { " (空文件) " }, full, 1
    end
    local n = #lines
    center_line = math.max(1, math.min(tonumber(center_line) or 1, n))
    local lo = math.max(1, center_line - ctx)
    local hi = math.min(n, center_line + ctx)
    local out = {
        string.format(" %s (行 %d) ", vim.fn.fnamemodify(full, ":t"), center_line),
        string.rep("─", math.min(60, #lines[1] + 20)),
    }
    for i = lo, hi do
        local mark = (i == center_line) and "▶" or " "
        table.insert(out, string.format("%s %4d │ %s", mark, i, lines[i]))
    end
    --- 前两行是标题/分隔线,代码从第 3 行起;▶ 所在行 = 3 + (center_line - lo)
    local mark_buf_line = 3 + (center_line - lo)
    return out, full, mark_buf_line
end

-- repo_root 由 actions/fzfnav 在 show() 时注入
M.state_repo_root = nil

---数据加载(labels / label / processes / search / modules)
M.fetch_labels = function()
    return M.run_tool({ "label" })
end
M.fetch_label = function(label_name)
    return M.run_tool({ "label", label_name })
end
M.fetch_processes = function(label_name)
    return M.run_tool({ "processes", label_name })
end
M.fetch_search = function(query)
    return M.run_tool({ "search", query })
end
M.fetch_modules = function(label_name)
    return M.run_tool({ "modules", label_name })
end

return M
