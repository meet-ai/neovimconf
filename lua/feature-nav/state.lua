-- feature-nav 全局状态 + 预览历史纯逻辑
local M = {}

---预览「标签」访问历史:与 [/] 循环配合,H/L 在记录中后退/前进
---@param idx integer
function M.preview_hist_reset(idx)
    M.preview_hist = { idx }
    M.preview_hist_pos = 1
end

---@param new_idx integer
function M.preview_hist_record_from_cycle(new_idx)
    if M.preview_hist_silent then
        return
    end
    local hist = M.preview_hist
    local pos = M.preview_hist_pos or 1
    if not hist or #hist == 0 then
        M.preview_hist_reset(new_idx)
        return
    end
    if pos < #hist and hist[pos + 1] == new_idx then
        M.preview_hist_pos = pos + 1
        return
    end
    if pos > 1 and hist[pos - 1] == new_idx then
        M.preview_hist_pos = pos - 1
        return
    end
    while #hist > pos do
        table.remove(hist)
    end
    if hist[pos] ~= new_idx then
        table.insert(hist, new_idx)
        M.preview_hist_pos = #hist
    end
end

-- 全局状态
M.win_left = nil
M.win_detail = nil
M.win_process = nil
M.win_code = nil
M.buf_left = nil
M.buf_detail = nil
M.buf_process = nil
M.buf_code = nil
---代码预览浮窗(独立居中窗口,P 打开)
M.buf_popout = nil
M.win_popout = nil
M.current_view = "labels"
M.labels = {}
M.selected_idx = 1
M.repo_root = nil
M.detail_cache = {}
M.search_items = {}
M.search_selected_idx = 1
---@type table[] 当前 Label 下 processes 命令结果
M.processes_for_label = {}
M.process_selected_idx = 1
---@type { file_path: string, line_number: integer }|nil
M.code_jump_ref = nil
---当前 Process 预览:链条上选中的位置 1..n
M.chain_loc_idx = 1
---用于切换 Process 时重置 chain_loc_idx
M.last_chain_process_id = nil
---预览标签浏览历史(chain_loc_idx 序列),配合 H / L
---@type integer[]
M.preview_hist = {}
M.preview_hist_pos = 1
---fill_code_buffer 时若为 true,不向 preview_hist 写入
M.preview_hist_silent = false

return M
