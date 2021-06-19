local utils = require('utils')

utils.map('n', '<Esc><Esc>', '<cmd>noh<CR>') -- Clear highlights
utils.map('n', '<Leader>%i', ':luafile ~/.config/nvim/init.lua<CR>')
utils.map('n', '<Leader>%v', ':source %<CR>')
utils.map('n', '<Leader>%l', ':luafile %<CR>')

utils.map('i', 'jk', '<Esc>') -- jk to escape

vim.api.nvim_exec([[

cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

vmap < <gv
vmap > >gv

nnoremap <silent> <M-left> <C-w>>
nnoremap <silent> <M-right> <C-w><
nnoremap <silent> <M-up> <C-w>+
nnoremap <silent> <M-down> <C-w>-

nnoremap <silent> <leader>H :call WinMove('h')<CR>
nnoremap <silent> <leader>J :call WinMove('j')<CR>
nnoremap <silent> <leader>K :call WinMove('k')<CR>
nnoremap <silent> <leader>L :call WinMove('l')<CR>

cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

nnoremap <Leader>pd :let &runtimepath.=','.escape(expand('%:p:h'), '\,')

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

noremap <leader><esc> :<C-u>set relativenumber!<CR>

nnoremap <silent> [g <C-o>
nnoremap <silent> ]g <C-i>

]], false)
