setlocal softtabstop=4 shiftwidth=4 tabstop=4 expandtab
setlocal foldmethod=syntax foldlevel=99 " all folds are initially unfolded

compiler gcc
setlocal makeprg=gcc\ -g\ -Wall\ -Wextra\ %\ -lcs50\ -o\ %:r

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
	" Echo 'Checking...' in the status bar immediately
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
	" Clean up: delete the temp file and redraw
	call delete(l:tmpfile)
	redraw!
endfunction

function! s:VimStyle50()
	if !executable('style50')
		echo: "Error: style50 is not executable"
		return
	endif
	let l:file = expand('%')
	let l:output = system('style50 --output split ' . shellescape(l:file))
	let l:lines = split(l:output, '\n')
	if len(l:lines) <= 2
		" Cleanly clear the command line and echo the second line
		redraw
		echo "style50: " . l:lines[1]
	else
		" Errors found: output to pager
		execute 'silent !style50 --output split ' . shellescape(l:file) .
					\ ' | tail -n +3 | head -n -1 | less -R --line-num-width=3 -N -S -c'
		redraw!
	endif
endfunction

command! -buffer VimCheck50 call s:VimCheck50()
command! -buffer VimStyle50 call s:VimStyle50()

if executable('check50')
	nnoremap <silent> <leader>ch <Cmd>VimCheck50<CR>
endif
if executable('style50')
	nnoremap <silent> <leader>s <Cmd>VimStyle50<CR>
	" Simpler command below
		"nnoremap <leader>s :<Cmd>style50-cli --output split % \| 
							\ tail --lines=+3 \| head --lines=-1 \|
							\ less --RAW-CONTROL-CHARS --LINE-NUMBERS<CR>:redraw!<CR>
endif
