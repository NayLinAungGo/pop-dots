setlocal softtabstop=4 shiftwidth=4 tabstop=4 expandtab
setlocal foldmethod=syntax foldlevel=99 " all folds are initially unfolded

compiler gcc
setlocal makeprg=gcc\ -g\ -Wall\ -Wextra\ -fsanitize=address\ %\ -lcs50\ -o\ %:r

" Compile Keybinds Mnemonics: 'cn' = 'compile now', 'ca' = 'compile all', 'cc' = 'compile continiously'
"nnoremap <leader>cn :!gcc -Wall -Wextra % -lcs50 && ./a.out<Space>
nnoremap <leader>cn :!gcc -Wall -Wextra % -lcs50 -o %:p:h/%:r && %:p:h/%:r<Space>
nnoremap <leader>ca <Cmd>!{ [ -x ./%:t:r ] && ./%:t:r ; } \|\| { \[ -x ./a.out \] && ./a.out ; }<CR>
"nnoremap <leader>cc :!gcc -Wall -Wextra % -lcs50 && while :; do ./a.out; done
nnoremap <leader>cc :!gcc -Wall -Wextra % -lcs50 && ./a.out<Space>


" Integration with CS50's check50 & style50
"
function! s:VimCheck50()
	if !executable('check50')
		echo: "Error: check50 is not executable"
		return
	endif
	" Filename without extension
	let l:filename = expand('%:t:r')
	let l:dir = expand('%:p:h')

	redraw
	echo "check50: Checking " . l:filename . "..."

	" cd into file's directory and run check50 with filename
	let l:cmd = 'cd ' . shellescape(l:dir) . ' && check50 --local --no-download-checks cs50/problems/2026/x/' . shellescape(l:filename)
	" Write the output to a temporary file in /tmp
	let l:output = system(l:cmd)
	let l:tmpfile = tempname()
	call writefile(split(l:output, "\n"), l:tmpfile)
	" Open pager on the temporary file
	execute 'silent !less +G -R ' . shellescape(l:tmpfile)

	call delete(l:tmpfile)
	redraw!
endfunction

function! s:VimStyle50()
	if !executable('style50')
		echo: "Error: style50 is not executable"
		return
	endif

	let l:file = expand('%')
	let l:output = systemlist('style50 --output split ' . shellescape(l:file))
	let l:lines = len(l:output)

	let l:tmpfile = tempname()
	call writefile(split(l:output, "\n"), l:tmpfile)

	if len(l:lines) <= 2
		redraw
		" echo the second line
		echo "style50: " . l:lines[1]
	else
		" Errors found: output to pager
		"execute 'silent !style50 --output split ' . shellescape(l:file) .
					\ ' | tail -n +3 | head -n -1 | less -R --line-num-width=3 -N -S -c'
		execute 'silent !cat ' . shellescape(l:tmpfile) .
					\ ' | tail -n +3 | head -n -1 | less -R --line-num-width=3 -N -S -c'
		redraw!
		echom "Score: " system('style50 --output score ' . shellescape(l:file))
	endif

	call delete(l:tmpfile)
endfunction

command! -buffer VimCheck50 call s:VimCheck50()
command! -buffer VimStyle50 call s:VimStyle50()

nnoremap <silent> <Leader>ch <Cmd>VimCheck50<CR>
nnoremap <silent> <Leader>s <Cmd>VimStyle50<CR>
