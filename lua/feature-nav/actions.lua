-- feature-nav 编排层:数据加载 + 状态流转 + 动作(调用 ui 渲染)
local state = require("feature-nav.state")
local util = require("feature-nav.util")
local client = require("feature-nav.gitnexus-client")
local ui = require("feature-nav.ui")

local M = {}

---@param t { file_path: string, line_number?: integer }
function M.open_jump_target(t)
    local path = client.resolve_workspace_path(t.file_path)
    if not path or vim.fn.filereadable(path) ~= 1 then
        vim.notify("无法打开文件: " .. tostring(t.file_path), vim.log.levels.WARN)
        return
    end
    local line = tonumber(t.line_number) or 1
    ui.close_all_wins()
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    if line > 1 then
        vim.fn.cursor(line, 1)
    end
    vim.cmd("normal! zz")
end

function M.jump_to_label_modules(label_name)
    if not label_name or label_name == "" then
        return
    end
    local result = client.fetch_modules(label_name)
    if result.status ~= "success" then
        vim.notify("feature-nav: " .. tostring(result.message or "modules 失败"), vim.log.levels.WARN)
        return
    end
    local targets = result.targets or {}
    if #targets == 0 then
        local comm = result.communities or {}
        if #comm > 0 then
            local np = #(result.processes or {})
            vim.notify(
                string.format(
                    "该 Label 含 %d 个 Community、%d 个 Process，但尚无 jump_targets。",
                    #comm,
                    np
                ),
                vim.log.levels.INFO
            )
        else
            vim.notify("未找到该 Label 下的跳转目标", vim.log.levels.WARN)
        end
        return
    end
    if #targets == 1 then
        M.open_jump_target(targets[1])
        return
    end
    vim.ui.select(targets, {
        prompt = "打开位置 (C=Community P=Process)",
        format_item = function(it)
            local ft = it.feature_type or "community"
            local tag = (ft == "process") and "P" or "C"
            return string.format("[%s] %s:%s", tag, it.file_path or "?", tostring(it.line_number or 1))
        end,
    }, function(choice)
        if choice then
            M.open_jump_target(choice)
        end
    end)
end

---预览历史:后退
function M.preview_hist_back()
    if state.preview_hist_pos <= 1 then
        return
    end
    state.preview_hist_pos = state.preview_hist_pos - 1
    state.chain_loc_idx = state.preview_hist[state.preview_hist_pos]
    state.preview_hist_silent = true
    ui.fill_code_buffer()
    state.preview_hist_silent = false
end

---预览历史:前进
function M.preview_hist_forward()
    local hist = state.preview_hist
    if not hist or state.preview_hist_pos >= #hist then
        return
    end
    state.preview_hist_pos = state.preview_hist_pos + 1
    state.chain_loc_idx = hist[state.preview_hist_pos]
    state.preview_hist_silent = true
    ui.fill_code_buffer()
    state.preview_hist_silent = false
end

---加载某 Label 的 Process 列表并刷新
function M.load_processes_for_label(label_name)
    state.processes_for_label = {}
    state.process_selected_idx = 1
    if not label_name or label_name == "" then
        ui.redraw_process_list()
        return
    end
    local r = client.fetch_processes(label_name)
    if r.status ~= "success" then
        state.processes_for_label = {}
        ui.redraw_process_list()
        return
    end
    local plist = r.processes
    if plist == nil or plist == vim.NIL or type(plist) ~= "table" then
        plist = {}
    end
    state.processes_for_label = plist
    ui.redraw_process_list()
end

---选中 Label 后刷新:详情 + Process 列表 + 代码
function M.load_preview_for_label(label_name)
    ui.fill_detail_buffer(label_name)
    M.load_processes_for_label(label_name)
end

function M.refresh_detail_preview()
    if state.current_view ~= "labels" then
        return
    end
    if #state.labels == 0 then
        ui.fill_detail_buffer(nil)
        M.load_processes_for_label(nil)
        return
    end
    local row = state.labels[state.selected_idx]
    if not row then
        ui.fill_detail_buffer(nil)
        M.load_processes_for_label(nil)
        return
    end
    M.load_preview_for_label(util.label_gitnexus_key(row))
end

function M.refresh_search_detail_preview()
    if state.current_view ~= "search" or #state.search_items == 0 then
        return
    end
    local idx = state.search_selected_idx or 1
    if idx < 1 or idx > #state.search_items then
        ui.fill_detail_buffer(nil)
        M.load_processes_for_label(nil)
        return
    end
    local item = state.search_items[idx]
    local pk = item and util.label_gitnexus_key(item)
    if pk then
        M.load_preview_for_label(pk)
    end
end

---左侧 Label 列表重绘(选中索引变化后)
function M.redraw_labels_arrows()
    if state.current_view ~= "labels" or #state.labels == 0 then
        return
    end
    state.selected_idx = math.max(1, math.min(state.selected_idx, #state.labels))
    local lines = {
        " j/k · Tab 切窗 ",
        string.rep("─", math.min(34, vim.api.nvim_win_get_width(state.win_left) - 2)),
    }
    for i, label in ipairs(state.labels) do
        local name = util.label_row_title(label)
        local nc = label.community_count or 0
        local np = label.process_count or 0
        local prefix = (i == state.selected_idx) and "▶" or " "
        table.insert(lines, string.format(" %s %s %d/%d", prefix, name, nc, np))
    end
    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_left, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", false)
    vim.api.nvim_win_set_cursor(state.win_left, { state.selected_idx + 2, 0 })
    M.refresh_detail_preview()
end

---渲染 Label 列表
function M.render_labels()
    local result = client.fetch_labels()
    local lines = {
        " j/k · Tab 切窗 ",
        string.rep("─", math.min(34, vim.api.nvim_win_get_width(state.win_left) - 2)),
    }

    if result.status ~= "success" then
        table.insert(lines, "")
        -- message 可能含换行(如 node 报错堆栈),必须压平,否则 nvim_buf_set_lines 报错
        local msg = tostring(result.message or ""):gsub("[\r\n]+", " "):sub(1, 100)
        table.insert(lines, " ⚠ " .. msg)
        vim.notify("feature-nav: label 失败", vim.log.levels.WARN)
        state.labels = {}
        state.current_view = "labels"
    else
        state.labels = result.results or {}
        state.current_view = "labels"
        if #state.labels == 0 then
            table.insert(lines, " (暂无) ")
        else
            state.selected_idx = math.max(1, math.min(state.selected_idx or 1, #state.labels))
            for i, label in ipairs(state.labels) do
                local name = util.label_row_title(label)
                local nc = label.community_count or 0
                local np = label.process_count or 0
                local prefix = (i == state.selected_idx) and "▶" or " "
                table.insert(lines, string.format(" %s %s  %d/%d", prefix, name, nc, np))
            end
        end
    end

    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_left, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", false)
    if #state.labels > 0 then
        vim.api.nvim_win_set_cursor(state.win_left, { state.selected_idx + 2, 0 })
    end
    M.refresh_detail_preview()
end

---渲染搜索结果
function M.render_search(query)
    local result = client.fetch_search(query)
    state.current_view = "search"
    state.search_items = {}
    state.search_selected_idx = 1

    local lines = {
        " j/k · Tab ",
        string.rep("─", math.min(34, vim.api.nvim_win_get_width(state.win_left) - 2)),
    }

    if result.status ~= "success" then
        table.insert(lines, " 搜索失败 ")
        vim.api.nvim_buf_set_option(state.buf_left, "modifiable", true)
        vim.api.nvim_buf_set_lines(state.buf_left, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(state.buf_left, "modifiable", false)
        M.load_preview_for_label(nil)
        return
    end

    for _, item in ipairs(result.results or {}) do
        if item.type == "label" then
            table.insert(state.search_items, item)
            --- item.feature_name = search API 的 llm_feature_name，即 Label 展示名
            table.insert(
                lines,
                string.format(" Label %s → %s", util.json_txt(item.label, "?"), util.json_txt(item.feature_name, ""))
            )
        end
    end

    if #state.search_items == 0 then
        table.insert(lines, " (无结果) ")
    end

    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_left, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf_left, "modifiable", false)

    if #state.search_items > 0 then
        state.search_selected_idx = 1
        vim.api.nvim_win_set_cursor(state.win_left, { 3, 0 })
        M.refresh_search_detail_preview()
    else
        M.load_preview_for_label(nil)
    end
end

---在预览窗内沿「入口 + 各步」循环移动
---@param delta integer
function M.chain_nav(delta)
    local procs = state.processes_for_label
    local p = procs[state.process_selected_idx]
    if not p then
        return
    end
    local locs = util.build_process_chain_locations(p)
    local n = #locs
    if n == 0 then
        return
    end
    local new_idx = ((state.chain_loc_idx - 1 + delta) % n + n) % n + 1
    state.chain_loc_idx = new_idx
    state.preview_hist_record_from_cycle(new_idx)
    ui.fill_code_buffer()
end

---跳到链条上第 n 段(与「▶ n. …」序号一致,1–9 键)
---@param n integer
function M.chain_goto(n)
    local procs = state.processes_for_label
    local p = procs[state.process_selected_idx]
    if not p then
        return
    end
    local locs = util.build_process_chain_locations(p)
    local m = #locs
    if m == 0 or n < 1 or n > m then
        return
    end
    state.chain_loc_idx = n
    state.preview_hist_record_from_cycle(n)
    ui.fill_code_buffer()
end

return M
