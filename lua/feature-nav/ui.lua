-- feature-nav UI 层:窗口/缓冲生命周期 + 渲染(不直接做数据加载)
local state = require("feature-nav.state")
local util = require("feature-nav.util")
local config = require("feature-nav.config")
local client = require("feature-nav.gitnexus-client")

local M = {}

---关闭代码预览浮窗
function M.close_code_popout()
    if state.win_popout and vim.api.nvim_win_is_valid(state.win_popout) then
        vim.api.nvim_win_close(state.win_popout, true)
    end
    state.win_popout = nil
    if state.buf_popout and vim.api.nvim_buf_is_valid(state.buf_popout) then
        vim.api.nvim_buf_delete(state.buf_popout, { force = true })
    end
    state.buf_popout = nil
end

---关闭全部 fzfnav 窗口并重置状态
function M.close_all_wins()
    M.close_code_popout()
    for _, w in ipairs({ state.win_left, state.win_detail, state.win_process, state.win_code }) do
        if w and vim.api.nvim_win_is_valid(w) then
            vim.api.nvim_win_close(w, true)
        end
    end
    state.win_left = nil
    state.win_detail = nil
    state.win_process = nil
    state.win_code = nil
    state.buf_left = nil
    state.buf_detail = nil
    state.buf_process = nil
    state.buf_code = nil
    state.code_jump_ref = nil
    state.chain_loc_idx = 1
    state.last_chain_process_id = nil
    state.preview_hist = {}
    state.preview_hist_pos = 1
    state.preview_hist_silent = false
end

---详情缓冲渲染(数据来自 client.fetch_label,带缓存)
function M.fill_detail_buffer(label_name)
    if not state.buf_detail or not vim.api.nvim_buf_is_valid(state.buf_detail) then
        return
    end
    if not label_name or label_name == "" then
        vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", true)
        vim.api.nvim_buf_set_lines(state.buf_detail, 0, -1, false, {
            " Label 详情 ",
            " ─── ",
            "",
            " ← 左侧选一项 Label",
        })
        vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", false)
        return
    end

    local cached = state.detail_cache[label_name]
    if not cached then
        local result = client.fetch_label(label_name)
        if result.status ~= "success" or result.label == nil or result.label == vim.NIL then
            vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", true)
            vim.api.nvim_buf_set_lines(state.buf_detail, 0, -1, false, {
                " Label 详情 ",
                " ─── ",
                "",
                " ⚠ " .. tostring(label_name),
            })
            vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", false)
            return
        end
        cached = result.label
        state.detail_cache[label_name] = cached
    end

    local label = cached
    --- 与左侧列表一致:无 LLM 名称时用 GitNexus label(如 Clustering)
    local title = util.label_row_title({
        llm_feature_name = label.llm_feature_name,
        label = label.label,
    })
    local display_name = util.json_txt(label.llm_feature_name, "")
    local desc = util.json_txt(label.llm_feature_description, "")
    local core = util.json_txt(label.llm_core_logic_summary, "")
    local uses = util.json_txt(label.llm_use_cases, "")
    local has_llm_body = display_name ~= "" or desc ~= "" or core ~= "" or uses ~= ""

    local lines = {
        string.format(" %s ", title),
        string.rep("─", 28),
    }
    if has_llm_body then
        table.insert(lines, string.format("Label 键: %s", util.json_txt(label.label, "?")))
        table.insert(lines, string.format("展示名: %s", display_name ~= "" and display_name or "—"))
        table.insert(lines, string.format("描述: %s", desc ~= "" and desc or "—"))
        table.insert(lines, string.format("核心: %s", core ~= "" and core or "—"))
        table.insert(lines, string.format("场景: %s", uses ~= "" and uses or "—"))
    else
        table.insert(lines, string.format(" Label 键: %s", util.json_txt(label.label, "?")))
        table.insert(lines, " （label_annotations 中 LLM 字段为空，可 save-label 写入）")
        table.insert(lines, " save-label 可补展示名/描述/核心/场景")
    end
    table.insert(lines, string.format("复杂度: %s/5", util.json_txt(label.llm_complexity, "3")))
    table.insert(lines, string.format("C×%d  P×%d", label.n_communities or 0, label.n_processes or 0))

    vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_detail, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf_detail, "modifiable", false)
    if state.win_detail and vim.api.nvim_win_is_valid(state.win_detail) then
        vim.api.nvim_win_call(state.win_detail, function()
            vim.cmd("normal! gg")
        end)
    end
end

---代码窗空态
function M.fill_code_empty(msg)
    if not state.buf_code or not vim.api.nvim_buf_is_valid(state.buf_code) then
        return
    end
    state.code_jump_ref = nil
    state.preview_hist = {}
    state.preview_hist_pos = 1
    vim.api.nvim_buf_set_option(state.buf_code, "filetype", "fzfnav")
    vim.api.nvim_buf_set_option(state.buf_code, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_code, 0, -1, false, {
        " 代码预览 ",
        " ─── ",
        "",
        " " .. (msg or "（无）"),
    })
    vim.api.nvim_buf_set_option(state.buf_code, "modifiable", false)
    M.close_code_popout()
end

---组装嵌入区/浮窗共用的预览文本
---@param p table|nil
---@param display_chain_idx integer
---@param tab_w integer
---@param code_ctx_lines integer
---@param footer_kind string "embed" | "popout"
---@return string[]|nil merged, integer|nil mark_buf_line, table|nil jump_ref
function M.compose_code_preview_lines(p, display_chain_idx, tab_w, code_ctx_lines, footer_kind)
    if not p then
        return nil
    end
    local locs = util.build_process_chain_locations(p)
    if #locs == 0 then
        return nil
    end
    local idx = math.max(1, math.min(display_chain_idx, #locs))
    local loc = locs[idx]

    local sep_w = math.min(50, math.max(28, math.floor((vim.o.columns or 80) * 0.25)))
    local sep = string.rep("─", sep_w)

    local list_only_embed = footer_kind == "embed" and not config.embed_show_code_snippet

    if list_only_embed then
        local tag_w = math.max(18, tonumber(config.embed_chain_tag_width) or 32)
        local llm_name = util.json_txt(p.llm_feature_name, "")
        local h_label = util.json_txt(p.heuristic_label, "")
        local g_label = util.json_txt(p.gitnexus_label, "")
        local desc = util.json_txt(p.llm_feature_description, "")
        local core = util.json_txt(p.llm_core_logic_summary, "")
        local uses = util.json_txt(p.llm_use_cases, "")
        local header_info = ""
        if llm_name ~= "" then
            header_info = string.format(" 【%s】分类:%s", llm_name, h_label)
        elseif g_label ~= "" then
            header_info = string.format(" 【%s】", g_label)
        end
        local merged = {
            string.format(
                " 链 %d/%d%s · [ ] Ctrl+p n · 1-9 · P 浮窗看代码 · Enter 打开 · H/L 历史 ",
                idx,
                #locs,
                header_info
            ),
            sep,
        }
        vim.list_extend(merged, util.build_chain_list_lines(locs, idx, tag_w))
        table.insert(merged, sep)
        if desc ~= "" or core ~= "" or uses ~= "" then
            if desc ~= "" then
                table.insert(merged, " " .. desc)
            end
            if core ~= "" then
                table.insert(merged, " 核心: " .. core)
            end
            if uses ~= "" then
                table.insert(merged, " 场景: " .. uses)
            end
        end
        table.insert(merged, "")
        table.insert(
            merged,
            " 本窗仅列表；按 P 弹出可读代码的浮窗 · Tab 切窗 · q 关全部 "
        )
        local mark_buf_line = 2 + idx
        local jump_ref = nil
        if loc.jumpable then
            jump_ref = { file_path = loc.file_path, line_number = loc.line_number }
        end
        return merged, mark_buf_line, jump_ref
    end

    local tab_line = util.format_chain_tab_bar(locs, idx, tab_w)
    local header = {
        tab_line ~= "" and tab_line or " （无标签）",
        string.format(
            " 第 %d/%d 段 · [ 或 Ctrl+p 上一段 · ] 或 Ctrl+n 下一段 · 1-9 跳到第 n 段 · H/L 预览浏览历史 ",
            idx,
            #locs
        ),
        sep,
    }
    vim.list_extend(header, util.build_chain_list_lines(locs, idx, 18))
    table.insert(header, string.rep("─", math.min(50, math.max(28, #(header[2] or "")))))

    local snippet
    local mark_buf_line
    local jump_ref
    if loc.jumpable then
        snippet, _, mark_buf_line = client.read_code_snippet(loc.file_path, loc.line_number, code_ctx_lines)
        if not snippet then
            snippet = {
                " (无法读文件) ",
                " " .. loc.file_path,
            }
            mark_buf_line = 1
        end
        jump_ref = { file_path = loc.file_path, line_number = loc.line_number }
    else
        snippet = {
            " (此步无 file_path，无法预览) ",
            " symbol_id: " .. util.json_txt(loc.symbol_id, "—"),
            "",
            " 可 sync 仓库以补全 process_steps ",
        }
        mark_buf_line = 1
        jump_ref = nil
    end

    local merged = {}
    for _, L in ipairs(header) do
        table.insert(merged, L)
    end
    local header_len = #merged
    for _, L in ipairs(snippet) do
        table.insert(merged, L)
    end
    if mark_buf_line then
        mark_buf_line = header_len + mark_buf_line
    end
    table.insert(merged, "")
    if footer_kind == "popout" then
        table.insert(
            merged,
            " 浮窗 · Ctrl+p/n 或 Alt+p/n 换段 · [/] · 1-9 · H/L · Enter 打开 · Esc/q 关浮窗 · P 刷新 "
        )
    else
        table.insert(
            merged,
            " P 放大浮窗 · [/] Ctrl+p n · 1-9 · Enter 打开 · Tab 切窗 · H/L 历史 · q 关全部 "
        )
    end
    return merged, mark_buf_line, jump_ref
end

---同步浮窗内容(浮窗打开时)
function M.sync_code_popout_buffer()
    if not state.win_popout or not vim.api.nvim_win_is_valid(state.win_popout) then
        return
    end
    if not state.buf_popout or not vim.api.nvim_buf_is_valid(state.buf_popout) then
        return
    end
    local procs = state.processes_for_label
    local p = procs[state.process_selected_idx]
    local w = vim.api.nvim_win_get_width(state.win_popout)
    local merged, mark_buf_line, jump_ref = M.compose_code_preview_lines(
        p,
        state.chain_loc_idx,
        w,
        config.popout_context_lines,
        "popout"
    )
    if not merged then
        return
    end
    state.code_jump_ref = jump_ref
    vim.api.nvim_buf_set_option(state.buf_popout, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_popout, 0, -1, false, merged)
    vim.api.nvim_buf_set_option(state.buf_popout, "modifiable", false)
    vim.api.nvim_buf_set_option(state.buf_popout, "filetype", "fzfnav")
    pcall(vim.api.nvim_win_set_config, state.win_popout, {
        title = string.format(" 预览浮窗 %d ", state.chain_loc_idx),
        title_pos = "center",
    })
    vim.api.nvim_win_call(state.win_popout, function()
        if mark_buf_line and mark_buf_line >= 1 then
            local last = vim.api.nvim_buf_line_count(state.buf_popout)
            local row = math.min(mark_buf_line, last)
            vim.api.nvim_win_set_cursor(0, { row, 0 })
            vim.cmd("normal! zz")
        else
            vim.cmd("normal! gg")
        end
    end)
end

---居中浮窗:更大上下文,链操作与嵌入预览同步(键位注册见 keys.register_popout_keys)
function M.open_code_popout()
    local procs = state.processes_for_label
    local p = procs[state.process_selected_idx]
    local locs = p and util.build_process_chain_locations(p) or {}
    if #locs == 0 then
        vim.notify("当前无代码可预览", vim.log.levels.INFO)
        return
    end
    M.close_code_popout()

    local cols = vim.o.columns or 80
    local lines = vim.o.lines or 24
    local w = math.min(110, math.max(56, cols - 8))
    local merged, mark_buf_line, jump_ref = M.compose_code_preview_lines(
        p,
        state.chain_loc_idx,
        w,
        config.popout_context_lines,
        "popout"
    )
    if not merged then
        return
    end
    state.code_jump_ref = jump_ref

    state.buf_popout = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.buf_popout, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(state.buf_popout, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_popout, 0, -1, false, merged)
    vim.api.nvim_buf_set_option(state.buf_popout, "modifiable", false)
    vim.api.nvim_buf_set_option(state.buf_popout, "filetype", "fzfnav")

    local h = math.min(lines - 4, math.max(14, #merged + 1))
    h = math.min(h, lines - 2)
    local row = math.max(0, math.floor((lines - h) / 2))
    local col = math.max(0, math.floor((cols - w) / 2))

    state.win_popout = vim.api.nvim_open_win(state.buf_popout, true, {
        relative = "editor",
        width = w,
        height = h,
        row = row,
        col = col,
        style = "minimal",
        border = "single",
        title = " 代码预览（浮窗） ",
        title_pos = "center",
    })
    vim.api.nvim_win_set_option(state.win_popout, "wrap", false)
    vim.api.nvim_win_set_option(state.win_popout, "number", false)

    vim.api.nvim_win_call(state.win_popout, function()
        if mark_buf_line and mark_buf_line >= 1 then
            local last = vim.api.nvim_buf_line_count(state.buf_popout)
            local row0 = math.min(mark_buf_line, last)
            vim.api.nvim_win_set_cursor(0, { row0, 0 })
            vim.cmd("normal! zz")
        end
    end)
end

---代码预览窗刷新(核心)
function M.fill_code_buffer()
    if not state.buf_code or not vim.api.nvim_buf_is_valid(state.buf_code) then
        return
    end
    local procs = state.processes_for_label
    local idx = state.process_selected_idx
    local p = procs[idx]
    if not p then
        state.last_chain_process_id = nil
        M.fill_code_empty("无 Process")
        return
    end

    local pid = util.json_txt(p.id, "")
    if pid ~= state.last_chain_process_id then
        state.last_chain_process_id = pid
        state.chain_loc_idx = 1
        state.preview_hist_reset(1)
    end

    local locs = util.build_process_chain_locations(p)
    if #locs == 0 then
        local ns = tonumber(p.gitnexus_step_count) or 0
        local nst = #util.json_array(p.steps)
        state.code_jump_ref = nil
        state.preview_hist = {}
        state.preview_hist_pos = 1
        M.fill_code_empty(
            string.format(
                "无可用位置（需 jump_targets 入口或 process_steps 含 file_path）。DB: step_count=%s steps行=%d",
                tostring(ns),
                nst
            )
        )
        return
    end

    state.chain_loc_idx = math.max(1, math.min(state.chain_loc_idx, #locs))

    if not state.preview_hist_silent and (#state.preview_hist == 0) then
        state.preview_hist_reset(state.chain_loc_idx)
    end

    local tab_w = 64
    if state.win_code and vim.api.nvim_win_is_valid(state.win_code) then
        tab_w = math.max(36, vim.api.nvim_win_get_width(state.win_code) - 2)
    end

    local merged, mark_buf_line, jump_ref =
        M.compose_code_preview_lines(p, state.chain_loc_idx, tab_w, config.code_context_lines, "embed")
    if not merged then
        return
    end
    state.code_jump_ref = jump_ref

    vim.api.nvim_buf_set_option(state.buf_code, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_code, 0, -1, false, merged)
    vim.api.nvim_buf_set_option(state.buf_code, "modifiable", false)
    vim.api.nvim_buf_set_option(state.buf_code, "filetype", "fzfnav")

    if state.win_code and vim.api.nvim_win_is_valid(state.win_code) then
        local title = string.format(" 链 %d/%d ", state.chain_loc_idx, #locs)
        pcall(vim.api.nvim_win_set_config, state.win_code, { title = title, title_pos = "center" })
        vim.api.nvim_win_call(state.win_code, function()
            if mark_buf_line and mark_buf_line >= 1 then
                local last = vim.api.nvim_buf_line_count(state.buf_code)
                local row = math.min(mark_buf_line, last)
                vim.api.nvim_win_set_cursor(0, { row, 0 })
                vim.cmd("normal! zz")
            else
                vim.cmd("normal! gg")
            end
        end)
    end

    M.sync_code_popout_buffer()
end

---Process 列表渲染
function M.redraw_process_list()
    if not state.buf_process or not vim.api.nvim_buf_is_valid(state.buf_process) then
        return
    end
    local lines = {
        " j/k 选流程 · 预览 P 浮窗 · [ ]/Ctrl+p n 换段 · Enter 打开 ",
        string.rep("─", 22),
    }
    local procs = state.processes_for_label
    if #procs == 0 then
        table.insert(lines, " (无 Process) ")
    else
        state.process_selected_idx = math.max(1, math.min(state.process_selected_idx, #procs))
        local any_j = false
        for i, proc in ipairs(procs) do
            local gl = util.process_row_title(proc)
            if #gl > 32 then
                gl = gl:sub(1, 29) .. "…"
            end
            local nj = #util.json_array(proc.jump_targets)
            local nsteps = #util.json_array(proc.steps)
            if nsteps == 0 and (proc.gitnexus_step_count or 0) > 0 then
                nsteps = proc.gitnexus_step_count
            end
            if nj > 0 then
                any_j = true
            end
            local prefix = (i == state.process_selected_idx) and "▶" or " "
            local mark = (proc.association == "shared_file") and "~" or " "
            table.insert(lines, string.format(" %s%s %s  s:%s j:%d", prefix, mark, gl, tostring(nsteps), nj))
        end
        if not any_j then
            table.insert(lines, "")
            table.insert(lines, " j:0 = DB 无 jump_targets")
            table.insert(lines, " 需写入跳转索引后才有代码预览")
        end
    end
    vim.api.nvim_buf_set_option(state.buf_process, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf_process, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf_process, "modifiable", false)
    if #procs > 0 then
        vim.api.nvim_win_set_cursor(state.win_process, { state.process_selected_idx + 2, 0 })
    end
    M.fill_code_buffer()
end

---4 窗布局创建
function M.open_split_layout()
    M.close_all_wins()
    state.detail_cache = {}
    state.processes_for_label = {}
    state.process_selected_idx = 1
    state.code_jump_ref = nil
    state.chain_loc_idx = 1
    state.last_chain_process_id = nil
    state.preview_hist = {}
    state.preview_hist_pos = 1
    state.preview_hist_silent = false

    local total_w = math.floor(vim.o.columns * 0.88)
    local height = math.floor(vim.o.lines * 0.74)
    local row0 = math.floor((vim.o.lines - height) / 2)
    local base_col = math.floor((vim.o.columns - total_w) / 2)

    local left_w = math.max(26, math.floor(total_w * config.left_width_ratio))
    local right_w = total_w - left_w
    local col_right = base_col + left_w

    local top_h = math.max(8, math.floor(height * config.preview_top_ratio))
    local code_h = height - top_h

    local proc_w = math.max(20, math.floor(right_w * 0.5))
    local detail_w = right_w - proc_w
    local col_proc = col_right
    local col_detail = col_right + proc_w
    local row_code = row0 + top_h

    state.buf_left = vim.api.nvim_create_buf(false, true)
    state.buf_detail = vim.api.nvim_create_buf(false, true)
    state.buf_process = vim.api.nvim_create_buf(false, true)
    state.buf_code = vim.api.nvim_create_buf(false, true)

    for _, b in ipairs({ state.buf_left, state.buf_detail, state.buf_process, state.buf_code }) do
        vim.api.nvim_buf_set_option(b, "bufhidden", "wipe")
        vim.api.nvim_buf_set_option(b, "filetype", "fzfnav")
    end

    state.win_left = vim.api.nvim_open_win(state.buf_left, true, {
        relative = "editor",
        width = left_w,
        height = height,
        row = row0,
        col = base_col,
        style = "minimal",
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    })

    state.win_process = vim.api.nvim_open_win(state.buf_process, false, {
        relative = "editor",
        width = proc_w,
        height = top_h,
        row = row0,
        col = col_detail,
        style = "minimal",
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    })

    state.win_detail = vim.api.nvim_open_win(state.buf_detail, false, {
        relative = "editor",
        width = detail_w,
        height = top_h,
        row = row0,
        col = col_proc,
        style = "minimal",
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    })

    state.win_code = vim.api.nvim_open_win(state.buf_code, false, {
        relative = "editor",
        width = right_w,
        height = code_h,
        row = row_code,
        col = col_right,
        style = "minimal",
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    })

    for _, w in ipairs({ state.win_left, state.win_detail, state.win_process, state.win_code }) do
        vim.api.nvim_win_set_option(w, "number", false)
    end
    vim.api.nvim_win_set_option(state.win_left, "cursorline", true)
    vim.api.nvim_win_set_option(state.win_process, "cursorline", true)
    vim.api.nvim_win_set_option(state.win_detail, "wrap", true)
    vim.api.nvim_win_set_option(state.win_process, "wrap", false)
    vim.api.nvim_win_set_option(state.win_code, "wrap", false)
end

return M
