if &term =~ '^xterm\|rxvt'
	" Blinking vertical bar in insert mode  
	let &t_SI = "\<Esc>[5 q"
	" Underline in replace mode
	let &t_SI .= "\<Esc>[4 q"
	" Solid block in other modes
	let &t_EI .= "\<Esc>[2 q"
endif
if &term =~ "xterm"
	let &t_SI = "\<Esc>[5 q"
	let &t_SR = "\<Esc>[4 q"
	let &t_EI = "\<Esc>[2 q"
endif

" Change cursor shape in different modes with tmux support
if exists('$TMUX')
	let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  	let &t_SR = "\<Esc>Ptmux;\<Esc>\e[4 q\<Esc>\\"
  	let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
endif
