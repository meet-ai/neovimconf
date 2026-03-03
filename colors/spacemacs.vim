" Spacemacs colorscheme for Neovim
" Based on the original Spacemacs theme

if exists('g:colors_name')
  unlet g:colors_name
endif
let g:colors_name = 'spacemacs'

if !has('nvim')
  echoerr 'This colorscheme requires Neovim'
  finish
endif

" Load the Lua module
lua << EOF
local ok, theme = pcall(require, 'themes.spacemacs')
if ok then
  theme.setup()
else
  vim.notify('Failed to load spacemacs theme: ' .. tostring(theme), vim.log.levels.ERROR)
end
EOF