let mapleader =" "
set keymap=burmese iminsert=0

" Escape insert mode:
	inoremap jk <Esc>

" Escape terminal mode:
"	tnoremap jk <C-\><C-N>

" Copy from current cursor position to the end of the line
" Makes Y work analogously to `D` and `C` (Not vi compatible)
	noremap Y y$

" Shortcutting split navigation, saving a keypress:
"	map <C-h> <C-w>h
"	map <C-j> <C-w>j
"	map <C-k> <C-w>k
"	map <C-l> <C-w>l
"augroup netrw_mapping
"    autocmd!
"	" <C-l> in netrw is mapped to netrw-refresh by default
"    autocmd filetype netrw nnoremap <buffer> <C-l> <C-w>l<CR>
"augroup END

" Replace all is aliased to S:
	"nnoremap S :%s//g<Left><Left>
	vnoremap S :s//g<Left><Left>

" Auto-closing braces:
	inoremap {<CR> {<CR>}<Esc>O

" Paste without replacing the buffer
	xnoremap <Leader>p "_dP

" Spell-check
	map <Leader>o <Cmd>setlocal spell!<CR>

" List bufers and prompt for selection
	nnoremap <Leader><Enter> <Cmd>buffers<CR>:b<Space>

nnoremap <Leader>bn <Cmd>bnext<CR>
nnoremap <Leader>bp <Cmd>bprevious<CR>
nnoremap <Leader>bd <Cmd>bdelete<CR>
nnoremap <Leader>bl <Cmd>buffers<CR>

" Function for toggling the bottom statusbar:
let s:hidden_all = 1
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
nnoremap <silent> <Leader>h <Cmd>call ToggleHiddenAll()<CR>

" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
