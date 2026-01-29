let mapleader =" "

" Escape insert mode:
	inoremap jk <Esc>

" Shortcutting split navigation, saving a keypress:
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l

" Replace all is aliased to S:
	"nnoremap S :%s//g<Left><Left>
	vnoremap S :s//g<Left><Left>

" Auto-closing braces:
	inoremap {<cr> {<cr>}<c-o>O

" Paste without replacing the buffer
	xnoremap <leader>p "_dP

" Spell-check
	map <leader>o :setlocal spell!<CR>

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
nnoremap <leader>h :call ToggleHiddenAll()<CR>
