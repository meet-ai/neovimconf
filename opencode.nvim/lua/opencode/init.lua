local vim = vim
local installer = require 'opencode.installer'
local state = require 'opencode.state'

local M = {}

local config = {
  keymaps = {
    toggle = nil,
    quit = '<C-q>', -- Default: Ctrl+q to quit
  },
  border = 'single',
  width = 0.8,
  height = 0.8,
  cmd = 'opencode',
  model = nil, -- Default to the latest model
  autoinstall = true,
  panel     = false,   -- if true, open Opencode in a side-panel instead of floating window
  use_buffer = false,  -- if true, capture Opencode stdout into a normal buffer instead of a terminal
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})

  vim.api.nvim_create_user_command('Opencode', function()
    M.toggle()
  end, { desc = 'Toggle Opencode popup' })

  vim.api.nvim_create_user_command('OpencodeToggle', function()
    M.toggle()
  end, { desc = 'Toggle Opencode popup (alias)' })

  vim.api.nvim_create_user_command('OpencodeAnalyze', function()
    M.analyze_selection()
  end, { desc = 'Analyze selected text with opencode' })

  if config.keymaps.toggle then
    vim.api.nvim_set_keymap('n', config.keymaps.toggle, '<cmd>OpencodeToggle<CR>', { noremap = true, silent = true })
  end
end

local function open_window()
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local styles = {
    single = {
      { '┌', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '┐', 'FloatBorder' },
      { '│', 'FloatBorder' },
      { '┘', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '└', 'FloatBorder' },
      { '│', 'FloatBorder' },
    },
    double = {
      { '╔', 'FloatBorder' },
      { '═', 'FloatBorder' },
      { '╗', 'FloatBorder' },
      { '║', 'FloatBorder' },
      { '╝', 'FloatBorder' },
      { '═', 'FloatBorder' },
      { '╚', 'FloatBorder' },
      { '║', 'FloatBorder' },
    },
    rounded = {
      { '╭', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '╮', 'FloatBorder' },
      { '│', 'FloatBorder' },
      { '╯', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '╰', 'FloatBorder' },
      { '│', 'FloatBorder' },
    },
    none = nil,
  }

  local border = type(config.border) == 'string' and styles[config.border] or config.border

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = border,
  })
end

--- Open Opencode in a side-panel (vertical split) instead of floating window
local function open_panel()
  -- Create a vertical split on the right and show the buffer
  vim.cmd('vertical rightbelow vsplit')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, state.buf)
  -- Adjust width according to config (percentage of total columns)
  local width = math.floor(vim.o.columns * config.width)
  vim.api.nvim_win_set_width(win, width)
  state.win = win
end

function M.open()
  local function create_clean_buf()
    local buf = vim.api.nvim_create_buf(false, false)

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'opencode')

    -- Apply configured quit keybinding

    if config.keymaps.quit then
      local quit_cmd = [[<cmd>lua require('opencode').close()<CR>]]
      vim.api.nvim_buf_set_keymap(buf, 't', config.keymaps.quit, [[<C-\><C-n>]] .. quit_cmd, { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(buf, 'n', config.keymaps.quit, quit_cmd, { noremap = true, silent = true })
    end

    return buf
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local check_cmd = type(config.cmd) == 'string' and not config.cmd:find '%s' and config.cmd or (type(config.cmd) == 'table' and config.cmd[1]) or nil

  if check_cmd and vim.fn.executable(check_cmd) == 0 then
    if config.autoinstall then
      installer.prompt_autoinstall(function(success)
        if success then
          M.open() -- Try again after installing
        else
          -- Show failure message *after* buffer is created
          if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
            state.buf = create_clean_buf()
          end
          vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {
            'Autoinstall cancelled or failed.',
            '',
            'You can install manually with:',
            '  npm install -g @openai/opencode',
          })
          if config.panel then open_panel() else open_window() end
        end
      end)
      return
    else
      -- Show fallback message
      if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        state.buf = vim.api.nvim_create_buf(false, false)
      end
      vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {
        'Opencode CLI not found, autoinstall disabled.',
        '',
        'Install with:',
        '  npm install -g @openai/opencode',
        '',
        'Or enable autoinstall in setup: require("opencode").setup{ autoinstall = true }',
      })
      if config.panel then open_panel() else open_window() end
      return
    end
  end

  local function is_buf_reusable(buf)
    return type(buf) == 'number' and vim.api.nvim_buf_is_valid(buf)
  end

  if not is_buf_reusable(state.buf) then
    state.buf = create_clean_buf()
  end

  if config.panel then open_panel() else open_window() end

  if not state.job then
    -- assemble command
    local cmd_args = type(config.cmd) == 'string' and { config.cmd } or vim.deepcopy(config.cmd)
    -- opencode does not support model parameter

    if config.use_buffer then
      -- capture stdout/stderr into normal buffer
      state.job = vim.fn.jobstart(cmd_args, {
        cwd = vim.loop.cwd(),
        stdout_buffered = true,
        on_stdout = function(_, data)
          if not data then return end
          for _, line in ipairs(data) do
            if line ~= '' then
              vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, { line })
            end
          end
        end,
        on_stderr = function(_, data)
          if not data then return end
          for _, line in ipairs(data) do
            if line ~= '' then
              vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, { '[ERR] ' .. line })
            end
          end
        end,
        on_exit = function(_, code)
          state.job = nil
          vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, {
            ('[Opencode exit: %d]'):format(code),
          })
        end,
      })
    else
      -- use a terminal buffer
      state.job = vim.fn.termopen(cmd_args, {
        cwd = vim.loop.cwd(),
        on_exit = function()
          state.job = nil
        end,
      })
      
      -- Send initial input if set
      if state.initial_input then
        vim.defer_fn(function()
          if state.job and state.initial_input then
            -- Clear current line (Ctrl+U) then send text then Enter
            vim.fn.chansend(state.job, "\x15") -- Ctrl+U (clear line)
            vim.fn.chansend(state.job, state.initial_input)
            vim.fn.chansend(state.job, "\r") -- Enter
            state.initial_input = nil
          end
        end, 200) -- Give terminal more time to initialize
      end
    end
  end
end

function M.analyze_selection()
  -- Get visual selection using getpos (works in visual mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  if not start_pos or #start_pos < 2 or not end_pos or #end_pos < 2 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end
  
  -- getpos returns [bufnum, line, col, offset]
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]
  
  -- Adjust for 0-indexed API
  local start_row = start_line - 1
  local end_row = end_line - 1
  
  -- For linewise selection, adjust columns
  local visual_mode = vim.fn.visualmode()
  if visual_mode == "V" then
    -- Linewise visual mode, select whole lines
    start_col = 0
    end_col = -1  -- to end of line
  elseif visual_mode == "v" then
    -- Characterwise visual mode
    if end_col > 0 then
      end_col = end_col + 1  -- exclusive
    end
  end
  
  -- Get selected text
  local selected_lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  local selected_text = table.concat(selected_lines, "\n")
  
  if selected_text == "" then
    vim.notify("Empty selection", vim.log.levels.WARN)
    return
  end
  
  -- Debug: show selected text
  vim.notify("Sending " .. #selected_text .. " chars to opencode", vim.log.levels.INFO)
  
  -- Open or focus opencode window
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    -- Window already open, send text directly
    vim.api.nvim_set_current_win(state.win)
    -- Send to terminal (ensure we're in insert mode)
    if state.job then
      -- Send Ctrl+U to clear line, then text, then Enter
      vim.fn.chansend(state.job, "\x15") -- Ctrl+U (clear line)
      vim.fn.chansend(state.job, selected_text)
      vim.fn.chansend(state.job, "\r") -- Enter
    end
  else
    -- Store initial input for when terminal opens
    state.initial_input = selected_text
    -- Open new window
    M.open()
  end
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.ask(prompt, opts)
  -- 禁用模态对话框，重定向到终端缓冲区
  vim.notify("Opencode ask 已禁用，使用终端缓冲区", vim.log.levels.INFO)
  M.open()
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

function M.statusline()
  if state.job and not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    return '[Opencode]'
  end
  return ''
end

function M.status()
  return {
    function()
      return M.statusline()
    end,
    cond = function()
      return M.statusline() ~= ''
    end,
    icon = '',
    color = { fg = '#51afef' },
  }
end

return setmetatable(M, {
  __call = function(_, opts)
    M.setup(opts)
    return M
  end,
})
