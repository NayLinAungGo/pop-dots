set smartindent

" Below is Markdown Table of Contents related functions yanked from preservim/vim-markdown
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

function! s:Toc(...)
	if a:0 > 0
		let l:window_type = a:1
	else
		let l:window_type = 'vertical'
	endif


	let l:cursor_line = line('.')
	let l:cursor_header = 0
	let l:header_list = s:GetHeaderList()
	let l:indented_header_list = []
	if len(l:header_list) == 0
		echomsg 'Toc: No headers.'
		return
	endif
	let l:header_max_len = 0
	let l:vim_markdown_toc_autofit = get(g:, 'vim_markdown_toc_autofit', 0)
	for h in l:header_list
		" set header number of the cursor position
		if l:cursor_header == 0
			let l:header_line = h.lnum
			if l:header_line == l:cursor_line
				let l:cursor_header = index(l:header_list, h) + 1
			elseif l:header_line > l:cursor_line
				let l:cursor_header = index(l:header_list, h)
			endif
		endif
		" indent header based on level
		let l:text = repeat('  ', h.level-1) . h.text
		" keep track of the longest header size (heading level + title)
		let l:total_len = strdisplaywidth(l:text)
		if l:total_len > l:header_max_len
			let l:header_max_len = l:total_len
		endif
		" append indented line to list
		let l:item = {'lnum': h.lnum, 'text': l:text, 'valid': 1, 'bufnr': h.bufnr, 'col': 1}
		let l:indented_header_list = l:indented_header_list + [l:item]
	endfor
	call setloclist(0, l:indented_header_list)

	if l:window_type ==# 'horizontal'
		topleft lopen
	elseif l:window_type ==# 'vertical'
		topleft vertical lopen
		" auto-fit toc window when possible to shrink it
		if (&columns/2) > l:header_max_len && l:vim_markdown_toc_autofit == 1
			" header_max_len + 1 space for first header + 3 spaces for line numbers
			execute 'vertical resize ' . (l:header_max_len + 1 + 3)
		else
			execute 'vertical resize ' . (&columns/2)
		endif
	elseif l:window_type ==# 'tab'
		tab lopen
	else
		lopen
	endif
	setlocal modifiable
	for i in range(1, line('$'))
		" this is the location-list data for the current item
		let d = getloclist(0)[i-1]
		call setline(i, d.text)
	endfor
	setlocal nomodified
	setlocal nomodifiable
	execute 'normal! ' . l:cursor_header . 'G'
endfunction

function! s:InsertToc(format, ...)
	if a:0 > 0
		if type(a:1) != type(0)
			echohl WarningMsg
			echomsg '[vim-markdown] Invalid argument, must be an integer >= 2.'
			echohl None
			return
		endif
		let l:max_level = a:1
		if l:max_level < 2
			echohl WarningMsg
			echomsg '[vim-markdown] Maximum level cannot be smaller than 2.'
			echohl None
			return
		endif
	else
		let l:max_level = 0
	endif

	let l:toc = []
	let l:header_list = s:GetHeaderList()
	if len(l:header_list) == 0
		echomsg 'InsertToc: No headers.'
		return
	endif

	if a:format ==# 'numbers'
		let l:h2_count = 0
		for header in l:header_list
			if header.level == 2
				let l:h2_count += 1
			endif
		endfor
		let l:max_h2_number_len = strlen(string(l:h2_count))
	else
		let l:max_h2_number_len = 0
	endif

	let l:h2_count = 0
	for header in l:header_list
		let l:level = header.level
		if l:level == 1
			" skip level-1 headers
			continue
		elseif l:max_level != 0 && l:level > l:max_level
			" skip unwanted levels
			continue
		elseif l:level == 2
			" list of level-2 headers can be bullets or numbers
			if a:format ==# 'bullets'
				let l:indent = ''
				let l:marker = '* '
			else
				let l:h2_count += 1
				let l:number_len = strlen(string(l:h2_count))
				let l:indent = repeat('  ', l:max_h2_number_len - l:number_len)
				let l:marker = l:h2_count . '. '
			endif
		else
			let l:indent = repeat('  ', l:max_h2_number_len + 2 * (l:level - 2))
			let l:marker = '* '
		endif
		let l:text = '[' . header.text . ']'
		let l:link = '(#' . substitute(tolower(header.text), '\v[ ]+', '-', 'g') . ')'
		let l:line = l:indent . l:marker . l:text . l:link
		let l:toc = l:toc + [l:line]
	endfor

	call append(line('.'), l:toc)
endfunction

command! -buffer Toc call s:Toc()
command! -buffer Toch call s:Toc('horizontal')
command! -buffer Tocv call s:Toc('vertical')
command! -buffer Toct call s:Toc('tab')
command! -buffer -nargs=? InsertToc call s:InsertToc('bullets', <args>)
command! -buffer -nargs=? InsertNToc call s:InsertToc('numbers', <args>)

nnoremap <Leader>t :Toc<CR>
nnoremap <Leader>T :InsertToc<CR>
