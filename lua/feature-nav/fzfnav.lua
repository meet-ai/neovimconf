-- fzfnav.lua - GitNexus Label 导航门面
-- 模块分层:
--   config.lua 配置常量 | util.lua 纯函数工具 | state.lua 状态+历史
--   gitnexus-client.lua CLI 调用+数据加载 | ui.lua 渲染/窗口 | actions.lua 编排 | keys.lua 键位
-- 外部接口:M.show(query) / M.search(query)(被 lua/core/keymaps.lua 调用)
local state = require("feature-nav.state")
local client = require("feature-nav.gitnexus-client")
local ui = require("feature-nav.ui")
local actions = require("feature-nav.actions")
local keys = require("feature-nav.keys")

local M = {}

---@param query string|nil 非空则进入搜索视图
local function show(query)
    state.selected_idx = 1
    local root = vim.env.FEATURE_NAV_REPO
    local repo_root = (root and root ~= "") and root or vim.fn.getcwd()
    state.repo_root = repo_root
    client.state_repo_root = repo_root

    ui.open_split_layout()

    if query and query ~= "" then
        actions.render_search(query)
    else
        actions.render_labels()
    end

    local ns = vim.api.nvim_create_namespace("fzfnav")
    for _, b in ipairs({ state.buf_left, state.buf_detail, state.buf_process, state.buf_code }) do
        vim.api.nvim_buf_add_highlight(b, ns, "Title", 0, 0, -1)
    end

    keys.map_keys()
    if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
        vim.api.nvim_set_current_win(state.win_left)
    end
end

M.show = show
M.search = function(query)
    show(query)
end

return M
