let g:netrw_banner = 0
let g:netrw_keepdir = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = -25
let g:netrw_altv = 0

function! ToggleNetrw()
	if exists("t:netrw_lexbufnr")
		" Close the netrw window if it's open
		let lexwinnr = bufwinnr(t:netrw_lexbufnr)
		if lexwinnr != -1
			" Switch to the netrw window
			exe lexwinnr . 'wincmd w'
			close " Close it
			let curwin = winnr() " Switch back to the previous window
			exe curwin . 'wincmd w'
		endif
		unlet t:netrw_lexbufnr
	else
		" Open netrw (Lexplore opens on the left)
		vertical Lexplore
		let t:netrw_lexbufnr = bufnr("%")
	endif
endfunction
nnoremap <silent> <C-e> :call ToggleNetrw()<CR>
