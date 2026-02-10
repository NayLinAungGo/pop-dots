setlocal smartindent
setlocal foldexpr=MarkdownFold() foldmethod=expr foldtext=MarkdownFoldText() foldlevel=99
let g:markdown_fenced_languages = ['c']

" Below is Markdown Table of Contents Insert yanked from preservim/vim-markdown

" For each level, contains the regexp that matches at that level only.
let s:levelRegexpDict = {
    \ 1: '\v^(#[^#]@=|.+\n\=+$)',
    \ 2: '\v^(##[^#]@=|.+\n-+$)',
    \ 3: '\v^###[^#]@=',
    \ 4: '\v^####[^#]@=',
    \ 5: '\v^#####[^#]@=',
    \ 6: '\v^######[^#]@='
\ }
" Matches any header level of any type.
let s:headersRegexp = '\v^(#|.+\n(\=+|-+)$)'
let g:vim_markdown_toc_autofit = 1

function! s:GetHeaderLineNum(...)
	if a:0 == 0
		let l:l = line('.')
	else
		let l:l = a:1
	endif
	while(l:l > 0)
	if join(getline(l:l, l:l + 1), "\n") =~ s:headersRegexp
		return l:l
	endif
	let l:l -= 1
	endwhile
	return 0
endfunction

function! s:GetHeaderLevel(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:linenum = s:GetHeaderLineNum(l:line)
	if l:linenum !=# 0
		return s:GetLevelOfHeaderAtLine(l:linenum)
	else
		return 0
	endif
endfunction

function! s:GetLevelOfHeaderAtLine(linenum)
	let l:lines = join(getline(a:linenum, a:linenum + 1), "\n")
	for l:key in keys(s:levelRegexpDict)
		if l:lines =~ get(s:levelRegexpDict, l:key)
			return l:key
		endif
	endfor
	return 0
endfunction

function! s:GetHeaderList()
	let l:bufnr = bufnr('%')
	let l:fenced_block = 0
	let l:front_matter = 0
	let l:header_list = []
	let l:fence_str = ''
	for i in range(1, line('$'))
		let l:lineraw = getline(i)
		let l:l1 = getline(i+1)
		let l:line = substitute(l:lineraw, '#', "\\\#", 'g')
		" exclude lines in fenced code blocks
		if l:line =~# '\v^[[:space:]>]*(`{3,}|\~{3,})\s*(\w+)?\s*$'
			if l:fenced_block == 0
				let l:fenced_block = 1
				let l:fence_str = matchstr(l:line, '\v(`{3,}|\~{3,})')
			elseif l:fenced_block == 1 && matchstr(l:line, '\v(`{3,}|\~{3,})') ==# l:fence_str
				let l:fenced_block = 0
				let l:fence_str = ''
			endif
		endif
		" match line against header regex
		if join(getline(i, i + 1), "\n") =~# s:headersRegexp && l:line =~# '^\S'
			let l:is_header = 1
		else
			let l:is_header = 0
		endif
		if l:is_header ==# 1 && l:fenced_block ==# 0 && l:front_matter ==# 0
			" remove hashes from atx headers
			if match(l:line, '^#') > -1
				let l:line = substitute(l:line, '\v^#*[ ]*', '', '')
				let l:line = substitute(l:line, '\v[ ]*#*$', '', '')
			endif
			" append line to list
			let l:level = s:GetHeaderLevel(i)
			let l:item = {'level': l:level, 'text': l:line, 'lnum': i, 'bufnr': bufnr}
			let l:header_list = l:header_list + [l:item]
		endif
	endfor
	return l:header_list
endfunction

function! s:InsertToc()
	let l:toc = []
	let l:header_list = s:GetHeaderList()
	if len(l:header_list) == 0
		echomsg 'InsertToc: No headers.'
		return
	endif

	for header in l:header_list
		let l:level = header.level
		if l:level == 1 " skip level-1 headers
			continue
		elseif l:level == 2
			let l:indent = ''
			let l:marker = '* '
		else
			let l:indent = repeat('  ', 2 * (l:level - 2))
			let l:marker = '* '
		endif
		let l:text = '[' . header.text . ']'
		let l:link = '(#' . substitute(tolower(header.text), '\v[ ]+', '-', 'g') . ')'
		let l:line = l:indent . l:marker . l:text . l:link
		let l:toc = l:toc + [l:line]
	endfor

	call append(line('.'), l:toc)
endfunction

command! -buffer -nargs=? InsertToc call s:InsertToc()
