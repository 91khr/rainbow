" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

let s:rainbow_conf = {
\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\	'guis': [''],
\	'cterms': [''],
\	'operators': '_,_',
\	'contains_prefix': 'TOP',
\	'parentheses_options': '',
\	'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/'],
\	'separately': {
\		'*': {},
\		'markdown': {
\			'parentheses_options': 'containedin=markdownCode contained',
\		},
\		'lisp': {
\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\		},
\		'haskell': {
\			'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
\		},
\		'ocaml': {
\			'parentheses': ['start=/(\ze[^*]/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\[|/ end=/|\]/ fold', 'start=/{/ end=/}/ fold'],
\		},
\		'tex': {
\			'parentheses_options': 'containedin=texDocZone',
\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\		},
\		'vim': {
\			'parentheses_options': 'containedin=vimFuncBody,vimExecute',
\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold'],
\		},
\		'xml': {
\			'syn_name_prefix': 'xmlRainbow',
\			'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
\		},
\		'xhtml': {
\			'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
\		},
\		'html': {
\			'parentheses': ['start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\		},
\		'lua': {
\			'parentheses': ['start=/(/ end=/)/', 'start=/{/ end=/}/', 'start=/\v\[\ze($|!(\=*\[))/ end=/\]/'],
\		},
\		'perl': {
\			'syn_name_prefix': 'perlBlockFoldRainbow',
\		},
\		'php': {
\			'syn_name_prefix': 'phpBlockRainbow',
\			'contains_prefix': '',
\			'parentheses': ['start=/(/ end=/)/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\[/ end=/\]/ containedin=@htmlPreproc contains=@phpClTop', 'start=/{/ end=/}/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold contains_prefix=TOP'],
\		},
\		'stylus': {
\			'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
\		},
\		'zsh': {
\			'parentheses': ['start=/{/ end=/}/', 'start=/\[/ end=/]/', 'start=/\V[[/ end=/]]/',
\				'start=/(/ end=/)/ contained containedin=zshMathSubst'],
\		},
\		'css': 0,
\		'sh': 0,
\		'vimwiki': 0,
\	}
\}

fun s:eq(x, y)
	return type(a:x) == type(a:y) && a:x == a:y
endfun

fun s:gcd(a, b)
	let [a, b, t] = [a:a, a:b, 0]
	while b != 0
		let t = b
		let b = a % b
		let a = t
	endwhile
	return a
endfun

fun s:lcm(a, b)
	return (a:a / s:gcd(a:a, a:b)) * a:b
endfun

fun rainbow_main#gen_config(ft)
	let usr_conf = get(g:, 'rainbow_conf', {})
	" Default conf
	let dft_conf = extendnew(s:rainbow_conf, usr_conf)
	unlet dft_conf.separately
	" Different separately conf
	let usrsep = get(usr_conf, 'separately', {})
	let defsep = s:rainbow_conf.separately
	" Fallback conf
	let fbk_conf = get(defsep, a:ft) ?? defsep['*']
	let spc_conf = get(usrsep, a:ft) ?? get(usrsep, '*', 'default')
	let fin_conf = s:eq(spc_conf, 'default') ? fbk_conf : spc_conf
	if s:eq(fin_conf, 0)
		return 0
	else
		let conf = { 'syn_name_prefix': substitute(a:ft, '\v\A+(\a)', '\u\1', 'g').'Rainbow' }
					\ ->extend(dft_conf)->extend(fin_conf)
		if conf->has_key('inherit')
			let conf.inherit = (type(conf.inherit) == v:t_string ? [conf.inherit] : conf.inherit)
						\ ->mapnew('rainbow_main#gen_config(v:val)')
		endif
		let conf.cycle = (has('gui_running') || (has('termguicolors') && &termguicolors)) ?
					\ s:lcm(len(conf.guifgs), len(conf.guis)) : s:lcm(len(conf.ctermfgs), len(conf.cterms))
		return conf
	endif
endfun

fun rainbow_main#gen_configs(ft)
	return filter(map(split(a:ft, '\v\.'), 'rainbow_main#gen_config(v:val)'), 'type(v:val) == type({})')
endfun

fun rainbow_main#load()
	let b:rainbow_confs = rainbow_main#gen_configs(&filetype)
	for conf in b:rainbow_confs
		call rainbow#syn(conf)
		call rainbow#hi(conf)
	endfor
endfun

fun rainbow_main#clear()
	if !exists('b:rainbow_confs') | return | endif
	for conf in b:rainbow_confs
		call rainbow#hi_clear(conf)
		call rainbow#syn_clear(conf)
	endfor
	unlet b:rainbow_confs
endfun

fun rainbow_main#toggle()
	if exists('b:rainbow_confs')
		call rainbow_main#clear()
	else
		call rainbow_main#load()
	endif
endfun

" vim: noet
