local M = {}

local colors = {}

function M.setup()
  vim.g.colors_name = "spacemacs"
  
  local is_dark = vim.o.background == "dark"
  
  if is_dark then
    colors = {
      -- Dark Colors (GUI values from Spacemacs)
      act1 = {"#222226", 235, "act1"},
      bg0 = {"#292b2e", 16, "bg0"},
      bg1 = {"#212026", 235, "bg1"},
      bg2 = {"#100a14", 233, "bg2"},
      bg3 = {"#0a0814", 16, "bg3"},
      bg4 = {"#34323e", 59, "bg4"},
      fg0 = {"#b2b2b2", 252, "fg0"},  -- Spacemacs base
      fg1 = {"#686868", 249, "fg1"},  -- Spacemacs base-dim
      fg2 = {"#8e8e8e", 245, "fg2"},
      fg3 = {"#727272", 243, "fg3"},
      fg4 = {"#9a9aba", 247, "fg4"},
      fg5 = {"#5e5079", 241, "fg5"},
      grey = {"#44505c", 239, "grey"},
      grey1 = {"#768294", 102, "grey1"},
      red1 = {"#ce537a", 168, "red1"},
      blue1 = {"#7590db", 68, "blue1"},
      purple0 = {"#a45bad", 104, "purple0"},  -- Spacemacs const
      purple1 = {"#bc6ec5", 177, "purple1"},  -- Spacemacs func
      purple2 = {"#a45bad", 245, "purple2"},
      purple3 = {"#5d4d7a", 241, "purple3"},
      purple4 = {"#34323e", 59, "purple4"},
      aqua0 = {"#2d9574", 30, "aqua0"},
      orange0 = {"#dc752f", 246, "orange0"},  -- Spacemacs war
      cyan = {"#28def0", 45, "cyan"},
      mat = {"#86dc2f", 245, "mat"},
      meta = {"#9f8766", 137, "meta"},
      spacelight = {"#444155", 238, "spacelight"},
      comp = {"#c56ec3", 248, "comp"},
      cblk = {"#cbc1d5", 252, "cblk"},
      ui_activ = {"#5d4d7a", 241, "ui_activ"},
      
      -- Terminal Colors (TER values from Spacemacs)
      tc8 = {"#585858", 240, "tc8"},      -- base-dim TER
      tc9 = {"#444444", 239, "tc9"},      -- lnum TER
      tc13 = {"#268bd2", 68, "tc13"},     -- head1 TER
      tc14 = {"#d75fd7", 104, "tc14"},    -- func TER
      tc15 = {"#2aa198", 30, "tc15"},     -- str TER
      tc16 = {"#d75fd7", 104, "tc16"},    -- const TER
    }
  else
    colors = {
      -- Light Colors (GUI values from Spacemacs) - Enhanced contrast
      act1 = {"#e7e5eb", 254, "act1"},
      bg0 = {"#fbf8ef", 255, "bg0"},
      bg1 = {"#efeae9", 255, "bg1"},
      bg2 = {"#e3dedd", 254, "bg2"},
      bg3 = {"#d2ceda", 252, "bg3"},
      bg4 = {"#a8a4ae", 248, "bg4"},
      fg0 = {"#1a1a1a", 234, "fg0"},      -- Dark foreground (near black)
      fg1 = {"#2a2a2a", 235, "fg1"},      -- Main foreground (dark gray)
      fg2 = {"#3a3a3a", 236, "fg2"},      -- Secondary foreground
      fg3 = {"#4a4a4a", 237, "fg3"},      -- Tertiary foreground
      fg4 = {"#6c3163", 240, "fg4"},      -- Dark purple
      fg5 = {"#8c799f", 103, "fg5"},
      grey = {"#888888", 245, "grey"},    -- Medium gray
      grey1 = {"#666666", 241, "grey1"},  -- Darker gray
      red1 = {"#cc3333", 160, "red1"},    -- Bright red
      blue1 = {"#3366cc", 68, "blue1"},   -- Bright blue
      purple0 = {"#990099", 90, "purple0"},  -- Darker, more saturated purple
      purple1 = {"#86589e", 97, "purple1"},
      purple2 = {"#4e3163", 239, "purple2"},
      purple3 = {"#d3d3e7", 253, "purple3"},
      purple4 = {"#e2e0ea", 188, "purple4"},
      aqua0 = {"#008866", 29, "aqua0"},   -- Bright green
      orange0 = {"#cc6600", 166, "orange0"},  -- Bright orange
      cyan = {"#21b8c7", 38, "cyan"},
      mat = {"#ba2f59", 125, "mat"},
      meta = {"#da8b55", 173, "meta"},
      spacelight = {"#d3d3e7", 253, "spacelight"},
      comp = {"#6c4173", 60, "comp"},
      cblk = {"#655370", 241, "cblk"},
      ui_activ = {"#fbf8ef", 255, "ui_activ"},
      
      -- Terminal Colors (TER values from Spacemacs)
      tc8 = {"#5f5f87", 238, "tc8"},      -- base TER
      tc9 = {"#af87af", 138, "tc9"},      -- lnum TER
      tc13 = {"#268bd2", 68, "tc13"},     -- head1 TER
      tc14 = {"#8700af", 240, "tc14"},    -- func TER
      tc15 = {"#2aa198", 29, "tc15"},     -- str TER
      tc16 = {"#8700af", 241, "tc16"},    -- const TER
    }
  end
  
  -- Common colors (regardless of background)
  colors.red = {"#f2241f", 196, "red"}
  colors.red0 = {"#f54e3c", 244, "red0"}
  colors.blue = {"#3366cc", 68, "blue"}    -- Brighter blue
  colors.blue0 = {"#0066cc", 68, "blue0"}  -- Darker blue for keywords
  colors.purple = {"#544a65", 59, "purple"}
  colors.green = {"#67b11d", 242, "green"}
  colors.green0 = {"#008888", 30, "green0"}  -- Brighter teal for comments
  colors.aqua = {"#4495b4", 244, "aqua"}
  colors.orange = {"#cc6600", 166, "orange"}  -- Brighter orange
  colors.yellow = {"#b1951d", 136, "yellow"}
  colors.yellow1 = {"#e5d11c", 247, "yellow1"}
  colors.war = {"#dc752f", 244, "war"}
  colors.number = {"#e697e6", 252, "number"}
  colors.debug = {"#ffc8c8", 224, "debug"}
  colors.float = {"#b7b7ff", 147, "float"}
  colors.delim = {"#74baac", 247, "delim"}
  
  -- Common terminal colors
  colors.tc2 = {"#d70000", 168, "tc2"}
  colors.tc3 = {"#67b11d", 73, "tc3"}
  colors.tc4 = {"#875f00", 244, "tc4"}
  colors.tc5 = {"#268bd2", 246, "tc5"}
  colors.tc6 = {"#af00df", 133, "tc6"}
  colors.tc7 = {"#00ffff", 240, "tc7"}
  colors.tc10 = {"#d70000", 196, "tc10"}
  colors.tc12 = {"#af00df", 133, "tc12"}
  
  -- Apply the colorscheme
  M._apply_highlights()
end

function M._apply_highlights()
  local NONE = {}
  local BG = "bg"
  local FG = "fg"
  
  local normal
  if vim.g.space_nvim_transparent_bg ~= true then
    normal = {fg = colors.fg1, bg = colors.bg0}
  else
    normal = {fg = colors.fg1, bg = NONE}
  end
  
  local highlight_groups = {
    Comment = {fg = colors.green0, style = 'italic'},
    Constant = {fg = colors.green0},
    String = {fg = colors.aqua0, style = 'italic'},
    Character = {fg = colors.purple0},
    Boolean = {fg = colors.war},
    Float = {fg = colors.float},
    Identifier = {fg = colors.blue},
    Function = {fg = colors.blue0, style = 'bold'},
    Statement = {fg = colors.blue0},
    Conditional = {fg = colors.blue0, style = 'bold'},
    Repeat = {fg = colors.red1, style = 'bold'},
    Label = {fg = colors.red1},
    Operator = {fg = colors.blue},
    Keyword = {fg = colors.blue0, style = 'bold'},
    Exception = {fg = colors.red},
    PreProc = {fg = colors.purple1},
    Include = {fg = colors.yellow},
    Define = {fg = colors.aqua0},
    Macro = {fg = colors.blue1, style = 'bold'},
    PreCondit = {fg = colors.purple2},
    Type = {fg = colors.red1},
    StorageClass = {fg = colors.yellow, style = 'bold'},
    Structure = {fg = colors.aqua, style = 'bold'},
    Typedef = {fg = colors.yellow},
    Special = {fg = colors.orange, style = 'italic'},
    SpecialChar = {fg = colors.cyan},
    Tag = {fg = colors.orange0},
    Delimiter = {fg = colors.delim},
    SpecialComment = {fg = colors.grey1},
    Debug = {fg = colors.red0},
    Underlined = {fg = colors.blue0, style = 'underline'},
    Ignore = {fg = colors.float},
    Error = {fg = colors.red, style = 'bold,reverse'},
    Todo = {fg = colors.orange0, style = 'bold,italic'},
    
    -- UI highlights
    ColorColumn = {fg = colors.fg0, bg = colors.bg1},
    Conceal = {fg = colors.blue0, bg = colors.bg0},
    Cursor = {fg = colors.orange0, style = 'bold,reverse'},
    CursorIM = {fg = colors.fg0, style = 'reverse'},
    Directory = {fg = colors.blue0, style = 'bold'},
    DiffAdd = {fg = colors.green, style = 'reverse'},
    DiffChange = {fg = colors.orange0, style = 'reverse'},
    DiffDelete = {fg = colors.red, style = 'reverse'},
    DiffText = {fg = colors.yellow, style = 'reverse'},
    EndOfBuffer = {fg = colors.bg0},
    ErrorMsg = {fg = colors.red1, bg = colors.bg1},
    VertSplit = {fg = colors.bg1},
    Folded = {fg = colors.purple2, bg = colors.bg1, style = 'italic'},
    FoldColumn = {fg = colors.purple0},
    SignColumn = {fg = colors.fg1},
    IncSearch = {fg = colors.orange0, style = 'bold,reverse'},
    LineNr = {fg = colors.grey},
    CursorLineNr = {fg = colors.purple0},
    MatchParen = {fg = colors.green, style = 'bold,underline'},
    ModeMsg = {fg = colors.yellow1},
    MoreMsg = {fg = colors.yellow1},
    NonText = {fg = colors.grey},
    Normal = normal,
    Pmenu = {fg = colors.fg5, bg = colors.purple4},
    PmenuSel = {fg = colors.fg0, bg = colors.fg6},
    PmenuSbar = {fg = colors.fg0, bg = colors.bg1},
    PmenuThumb = {fg = colors.fg0, bg = colors.purple3},
    Question = {fg = colors.orange0, style = 'bold'},
    QuickFixLine = {fg = colors.green, style = 'bold,reverse'},
    qfLineNr = {fg = colors.red1},
    Search = {fg = colors.green, style = 'bold,reverse'},
    SpecialKey = {fg = colors.purple0},
    SpellBad = {fg = colors.red, style = 'italic,undercurl'},
    SpellCap = {fg = colors.blue0, style = 'italic,undercurl'},
    SpellLocal = {fg = colors.aqua0, style = 'italic,undercurl'},
    SpellRare = {fg = colors.purple0, style = 'italic,undercurl'},
    StatusLine = {fg = colors.fg0, bg = colors.act1},
    StatusLineNC = {fg = colors.purple3, bg = colors.purple4},
    StatusLineTerm = {fg = colors.fg0, bg = colors.act1},
    StatusLineTermNC = {fg = colors.purple3, bg = colors.purple4},
    TabLineFill = {fg = colors.purple, bg = colors.bg1},
    TabLineSel = {fg = colors.green, bg = colors.bg1},
    TabLine = {fg = colors.purple, bg = colors.bg1},
    Title = {fg = colors.green, style = 'bold'},
    Visual = {fg = colors.fg0, bg = colors.spacelight},
    VisualNOS = {fg = colors.fg0, bg = colors.spacelight},
    WarningMsg = {fg = colors.red},
    WildMenu = {fg = colors.orange0, bg = colors.bg1, style = 'bold'},
    
    CursorColumn = {bg = colors.bg1},
    CursorLine = {bg = colors.bg1},
    ToolbarLine = {fg = colors.fg0, bg = colors.bg3},
    ToolbarButton = {fg = colors.fg0, bg = colors.bg3, style = 'bold'},
    NormalMode = {fg = colors.fg4, style = 'reverse'},
    InsertMode = {fg = colors.blue0, style = 'reverse'},
    ReplaceMode = {fg = colors.aqua0, style = 'reverse'},
    VisualMode = {fg = colors.spacelight, style = 'reverse'},
    CommandMode = {fg = colors.purple0, style = 'reverse'},
    Warnings = {fg = colors.orange0, style = 'reverse'},
  }
  
  -- Apply highlights using nvim_set_hl
  for group, attrs in pairs(highlight_groups) do
    local hl_attrs = {}
    
    if attrs.fg then
      hl_attrs.fg = type(attrs.fg) == 'table' and attrs.fg[1] or attrs.fg
    end
    if attrs.bg then
      hl_attrs.bg = type(attrs.bg) == 'table' and attrs.bg[1] or attrs.bg
    end
    if attrs.style then
      -- Parse style string like 'bold,italic' into table
      local styles = {}
      for style in string.gmatch(attrs.style, '[^,]+') do
        table.insert(styles, style)
      end
      if #styles > 0 then
        hl_attrs[styles[1]] = true
        for i = 2, #styles do
          hl_attrs[styles[i]] = true
        end
      end
    end
    
    vim.api.nvim_set_hl(0, group, hl_attrs)
  end
  
  -- Tree-sitter highlight groups (link to traditional groups for better visibility)
  local ts_highlight_groups = {
    ["@function"] = "Function",
    ["@function.call"] = "Function",
    ["@method"] = "Function",
    ["@method.call"] = "Function",
    ["@parameter"] = "Identifier",
    ["@variable.parameter"] = "Identifier",
    ["@property"] = "Identifier",
    ["@variable"] = "Identifier",
    ["@constant"] = "Constant",
    ["@type"] = "Type",
    ["@keyword"] = "Keyword",
    ["@string"] = "String",
    ["@comment"] = "Comment",
    ["@number"] = "Number",
    ["@boolean"] = "Boolean",
  }
  
  for ts_group, link_group in pairs(ts_highlight_groups) do
    vim.api.nvim_set_hl(0, ts_group, { link = link_group })
  end
  
  -- Set terminal colors
  local terminal_ansi_colors = {
    [0] = colors.bg0,
    [1] = colors.tc2,
    [2] = colors.tc3,
    [3] = colors.tc4,
    [4] = colors.tc5,
    [5] = colors.tc6,
    [6] = colors.tc7,
    [7] = colors.tc8,
    [8] = colors.red,
    [9] = colors.green,
    [10] = colors.tc6,
    [11] = colors.tc12,
    [12] = colors.tc13,
    [13] = colors.tc14,
    [14] = colors.tc15,
    [15] = colors.tc13,
  }
  
  for i, color in ipairs(terminal_ansi_colors) do
    if color then
      vim.g['terminal_color_' .. (i-1)] = type(color) == 'table' and color[1] or color
    end
  end
end

-- Function to toggle between dark and light mode
function M.toggle()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  M.setup()
end

-- Register as a colorscheme
vim.api.nvim_create_user_command('SpacemacsToggle', function()
  M.toggle()
end, {})

-- Make it available as a colorscheme
vim.cmd([[
  function! SpacemacsTheme(...)
    lua require('themes.spacemacs').setup()
  endfunction
  command! -nargs=* ColorschemeSpacemacs call SpacemacsTheme(<f-args>)
]])

-- Also register it as a proper colorscheme
local group = vim.api.nvim_create_augroup('SpacemacsTheme', { clear = true })
vim.api.nvim_create_autocmd('ColorSchemePre', {
  group = group,
  pattern = 'spacemacs',
  callback = function()
    vim.g.colors_name = 'spacemacs'
  end,
})

return M