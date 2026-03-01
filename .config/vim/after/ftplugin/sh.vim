" Check file in shellcheck:
	noremap <leader>s <Cmd>!clear && shellcheck %<CR>

" Make current script executable
	nnoremap <leader>x <cmd>!chmod +x %<CR>

compiler shellcheck
