-- feature-nav 键位注册:主窗 4 buffer + 代码预览浮窗
local state = require("feature-nav.state")
local util = require("feature-nav.util")
local ui = require("feature-nav.ui")
local actions = require("feature-nav.actions")

local M = {}

---浮窗内链操作键位(独立居中窗口打开时注册)
---@param buf integer
function M.register_popout_keys(buf)
    -- 浮窗内避免与全局 Ctrl 映射冲突:schedule + buffer 局部 + nowait;终端若占 Ctrl 可用 Alt+p/n
    local map_pop = { buffer = buf, silent = true, nowait = true, noremap = true }
    local function pop_chain(d)
        return function()
            vim.schedule(function()
                actions.chain_nav(d)
            end)
        end
    end
    vim.keymap.set("n", "q", ui.close_code_popout, map_pop)
    vim.keymap.set("n", "<Esc>", ui.close_code_popout, map_pop)
    vim.keymap.set("n", "<CR>", function()
        if state.code_jump_ref then
            actions.open_jump_target(state.code_jump_ref)
        end
    end, map_pop)
    vim.keymap.set("n", "[", pop_chain(-1), map_pop)
    vim.keymap.set("n", "]", pop_chain(1), map_pop)
    vim.keymap.set("n", "<C-p>", pop_chain(-1), map_pop)
    vim.keymap.set("n", "<C-n>", pop_chain(1), map_pop)
    vim.keymap.set("n", "<M-p>", pop_chain(-1), map_pop)
    vim.keymap.set("n", "<M-n>", pop_chain(1), map_pop)
    for d = 1, 9 do
        local k = d
        vim.keymap.set("n", tostring(d), function()
            vim.schedule(function()
                actions.chain_goto(k)
            end)
        end, map_pop)
    end
    vim.keymap.set("n", "H", function()
        vim.schedule(actions.preview_hist_back)
    end, map_pop)
    vim.keymap.set("n", "L", function()
        vim.schedule(actions.preview_hist_forward)
    end, map_pop)
    vim.keymap.set("n", "j", function()
        vim.cmd("normal! j")
    end, map_pop)
    vim.keymap.set("n", "k", function()
        vim.cmd("normal! k")
    end, map_pop)
    vim.keymap.set("n", "P", function()
        ui.close_code_popout()
        ui.open_code_popout()
    end, map_pop)
end

---主窗键位(4 个 buffer)
function M.map_keys()
    local function do_quit()
        ui.close_all_wins()
    end

    local function focus_cycle()
        local order = { state.win_left, state.win_detail, state.win_process, state.win_code }
        local cur = vim.api.nvim_get_current_win()
        local ix = 1
        for i, w in ipairs(order) do
            if w and vim.api.nvim_win_is_valid(w) and cur == w then
                ix = i
                break
            end
        end
        local next_ix = (ix % #order) + 1
        local nw = order[next_ix]
        if nw and vim.api.nvim_win_is_valid(nw) then
            vim.api.nvim_set_current_win(nw)
        end
    end

    local function label_name_for_jump()
        if state.current_view == "labels" and #state.labels > 0 then
            local r = state.labels[state.selected_idx]
            return r and util.label_gitnexus_key(r)
        end
        if state.current_view == "search" and #state.search_items > 0 then
            local idx = state.search_selected_idx or 1
            local it = state.search_items[idx]
            return it and util.label_gitnexus_key(it)
        end
        return nil
    end

    local function enter_action()
        local cw = vim.api.nvim_get_current_win()

        if cw == state.win_code then
            if state.code_jump_ref then
                actions.open_jump_target(state.code_jump_ref)
            else
                vim.notify("当前段无路径：在预览窗按 [ ] 或 Ctrl+p/n 换到其它代码段", vim.log.levels.INFO)
            end
            return
        end

        if cw == state.win_process then
            if state.code_jump_ref then
                actions.open_jump_target(state.code_jump_ref)
                return
            end
            local procs = state.processes_for_label
            local p = procs[state.process_selected_idx]
            local jlist = p and util.json_array(p.jump_targets) or {}
            local jt = jlist[1]
            if jt and util.json_txt(jt.file_path, "") ~= "" then
                actions.open_jump_target(jt)
            else
                vim.notify("当前段无路径：焦点切到右侧预览窗，用 [ ] 或 1-9 换段", vim.log.levels.INFO)
            end
            return
        end

        if cw == state.win_detail then
            local ln = label_name_for_jump()
            if ln then
                actions.jump_to_label_modules(ln)
            end
            return
        end

        if cw == state.win_left then
            if state.current_view == "labels" and #state.labels > 0 then
                local idx = vim.fn.line(".") - 2
                if idx >= 1 and idx <= #state.labels then
                    state.selected_idx = idx
                    local label = state.labels[idx]
                    local lk = util.label_gitnexus_key(label)
                    if lk then
                        actions.jump_to_label_modules(lk)
                    end
                end
            elseif state.current_view == "search" and #state.search_items > 0 then
                local idx = vim.fn.line(".") - 2
                if idx >= 1 and idx <= #state.search_items then
                    state.search_selected_idx = idx
                    local item = state.search_items[idx]
                    local sk = util.label_gitnexus_key(item)
                    if sk then
                        actions.jump_to_label_modules(sk)
                    end
                end
            end
        end
    end

    local function labels_j()
        if state.current_view ~= "labels" or #state.labels == 0 then
            return
        end
        local max_line = 2 + #state.labels
        if vim.fn.line(".") < max_line then
            vim.cmd("normal! j")
            state.selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.labels))
            actions.redraw_labels_arrows()
        end
    end

    local function labels_k()
        if state.current_view ~= "labels" or #state.labels == 0 then
            return
        end
        if vim.fn.line(".") > 3 then
            vim.cmd("normal! k")
            state.selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.labels))
            actions.redraw_labels_arrows()
        end
    end

    local function search_j()
        if state.current_view ~= "search" or #state.search_items == 0 then
            return
        end
        if vim.fn.line(".") < 2 + #state.search_items then
            vim.cmd("normal! j")
            state.search_selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.search_items))
            actions.refresh_search_detail_preview()
        end
    end

    local function search_k()
        if state.current_view ~= "search" or #state.search_items == 0 then
            return
        end
        if vim.fn.line(".") > 3 then
            vim.cmd("normal! k")
            state.search_selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.search_items))
            actions.refresh_search_detail_preview()
        end
    end

    local function process_j()
        if #state.processes_for_label == 0 then
            return
        end
        local max_line = 2 + #state.processes_for_label
        if vim.fn.line(".") < max_line then
            vim.cmd("normal! j")
            state.process_selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.processes_for_label))
            ui.redraw_process_list()
        end
    end

    local function process_k()
        if #state.processes_for_label == 0 then
            return
        end
        if vim.fn.line(".") > 3 then
            vim.cmd("normal! k")
            state.process_selected_idx = math.max(1, math.min(vim.fn.line(".") - 2, #state.processes_for_label))
            ui.redraw_process_list()
        end
    end

    local all_bufs = { state.buf_left, state.buf_detail, state.buf_process, state.buf_code }
    for _, b in ipairs(all_bufs) do
        vim.keymap.set("n", "q", do_quit, { buffer = b })
        vim.keymap.set("n", "<Tab>", focus_cycle, { buffer = b })
        vim.keymap.set("n", "<CR>", enter_action, { buffer = b })
    end

    vim.keymap.set("n", "j", function()
        if state.current_view == "labels" then
            labels_j()
        elseif state.current_view == "search" then
            search_j()
        else
            vim.cmd("normal! j")
        end
    end, { buffer = state.buf_left })

    vim.keymap.set("n", "k", function()
        if state.current_view == "labels" then
            labels_k()
        elseif state.current_view == "search" then
            search_k()
        else
            vim.cmd("normal! k")
        end
    end, { buffer = state.buf_left })

    vim.keymap.set("n", "j", process_j, { buffer = state.buf_process })
    vim.keymap.set("n", "k", process_k, { buffer = state.buf_process })
    vim.keymap.set("n", "P", function()
        ui.open_code_popout()
    end, { buffer = state.buf_process })

    vim.keymap.set("n", "j", function()
        vim.cmd("normal! j")
    end, { buffer = state.buf_detail })
    vim.keymap.set("n", "k", function()
        vim.cmd("normal! k")
    end, { buffer = state.buf_detail })

    vim.keymap.set("n", "j", function()
        vim.cmd("normal! j")
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "k", function()
        vim.cmd("normal! k")
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "[", function()
        actions.chain_nav(-1)
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "]", function()
        actions.chain_nav(1)
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "<C-p>", function()
        actions.chain_nav(-1)
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "<C-n>", function()
        actions.chain_nav(1)
    end, { buffer = state.buf_code })
    for d = 1, 9 do
        vim.keymap.set("n", tostring(d), function()
            actions.chain_goto(d)
        end, { buffer = state.buf_code })
    end
    vim.keymap.set("n", "H", function()
        actions.preview_hist_back()
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "L", function()
        actions.preview_hist_forward()
    end, { buffer = state.buf_code })
    vim.keymap.set("n", "P", function()
        ui.open_code_popout()
    end, { buffer = state.buf_code })

    vim.keymap.set("n", "l", function()
        if state.win_detail and vim.api.nvim_win_is_valid(state.win_detail) then
            vim.api.nvim_set_current_win(state.win_detail)
        end
    end, { buffer = state.buf_left })

    vim.keymap.set("n", "h", function()
        if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
            vim.api.nvim_set_current_win(state.win_left)
        end
    end, { buffer = state.buf_detail })

    vim.keymap.set("n", "h", function()
        if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
            vim.api.nvim_set_current_win(state.win_left)
        end
    end, { buffer = state.buf_process })

    vim.keymap.set("n", "h", function()
        if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
            vim.api.nvim_set_current_win(state.win_left)
        end
    end, { buffer = state.buf_code })
end

return M
