let g:load_doxygen_syntax=1

" mnemonics 'cs' = 'compile now', 'ca' = 'compile all'
nnoremap <leader>cn :!gcc -Wall -Wextra % -lcs50 && ./a.out<CR>
nnoremap <leader>cr :!./a.out \|\| ./%<CR>
nnoremap <leader>ca :!gcc -Wall -Wextra % -lcs50 && while :; do ./a.out; done<CR>

compiler gcc
setlocal makeprg=gcc\ -Wall\ -Wextra\ -o\ %<\ %\ -lcs50
