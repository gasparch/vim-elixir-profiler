
" Vim-Elixir-Profiler brings better support of Erlang eprof and fprof
" profiling outputs to Vim - highlight and navigation of profile/code
"

let s:BOOT_FINISHED = 0
let s:PARSE_EPROF_LINE = '^\(\S\+:\S\+\/\d\+\)\s\+\(\d\+\)\s\+\([0-9.]\+\)\s\+\(\d\+\)\s\+\[\s*\([0-9.]\+\)\s*\]$'
let s:PARSE_FUN_NAME = '^\(\S\+\):\(\S\+\)\/\(\d\+\)$'

function! vimelixirprofiler#boot(filetype) " {{{
  if !s:BOOT_FINISHED
      call vimelixirprofiler#bootGlobal()
      let s:BOOT_FINISHED = 1
  endif

  call vimelixirprofiler#setDefaults(a:filetype)

  " this happens in each buffer
  call vimelixirprofiler#setProfilerSortCommands()
  "if g:vim_elixir_exunit_tests    | call vimelixirprofiler#setExUnitRunCommands() | endif
endfunction " }}}

function! vimelixirprofiler#setDefaults(filetype) "{{{
  let &filetype = g:vim_elixir_profiler_mode . "-" . a:filetype

  setlocal cursorline
  setlocal readonly
endfunction "}}}

function! vimelixirprofiler#bootGlobal() " {{{
  call s:setGlobal('g:vim_elixir_profiler_mode', 'elixir')
endfunction " }}}

" translates eprof file from Erlang style to Elixir
function! vimelixirprofiler#read(filetype) " {{{
    if g:vim_elixir_profiler_mode == 'elixir' 
        if a:filetype == "eprof" 
            call vimelixirprofiler#readEprof()
        endif
    endif

endfunction " }}}

function! vimelixirprofiler#readEprof() " {{{
  " make 'patchmode' empty, we don't want a copy of the written file
  let pm_save = &pm
  set pm=
  " remove 'a' and 'A' from 'cpo' to avoid the alternate file changes
  let cpo_save = &cpo
  set cpo-=a cpo-=A
  " set 'modifiable'
  let ma_save = &ma
  setlocal ma
  " set 'write'
  let write_save = &write
  set write
  " Reset 'foldenable', otherwise line numbers get adjusted.
  if has("folding")
    let fen_save = &fen
    setlocal nofen
  endif

  let firstline = 1
  let lastline = line('$')

  let lines = getline(firstline, lastline)
  let b:originalLines = lines

  for linenum in range(firstline, lastline)
      let line_txt = vimelixirprofiler#translateElixirLine(linenum, lines[linenum-1])
      call setline(linenum, line_txt)
  endfor

  " Restore saved option values.
  let &pm = pm_save
  let &cpo = cpo_save
  let &l:ma = ma_save
  let &write = write_save
  if has("folding")
    let &l:fen = fen_save
  endif
endfunction " }}}

function! vimelixirprofiler#translateElixirLine(lineNo, line) " {{{
    if a:lineNo < 3
        return a:line
    endif

    let parsedLine = s:parseLine(a:line)
    if parsedLine == []
        return a:line
    end

    let [ funName, callsNo, percentage, totalTime, usecsPerCall ] = parsedLine

    let newfunName = s:translateErlangNameToElixir(funName)

    let firstNonEmptyAfterFunction = match(a:line, '\S', len(funName)+1)

    let newLine = printf("%-*s%s", firstNonEmptyAfterFunction+1, newfunName, strpart(a:line, firstNonEmptyAfterFunction))

    return newLine
endfunction " }}}

function! vimelixirprofiler#sortByColumn(bang, column) " {{{
    let prefix = '3,$-2sort' . a:bang . ' '

    if a:column == 0 
        let command = prefix
    elseif a:column == 1
        let command = prefix . ' /^\S\+\s\+\ze\d/ n'
    elseif a:column == 2
        let command = prefix . ' /^\S\+\s\+\d\+\s\+\ze\d/ f'
    elseif a:column == 3
        let command = prefix . ' /^\S\+\s\+\d\+\s\+[0-9.]\+\s\+\ze\d/ n'
    elseif a:column == 4
        let command = prefix . ' /^\S\+\s\+\d\+\s\+[0-9.]\+\s\+\d\+\s\+\[\s*\ze\d/ f'
    endif

    set noreadonly
    exec command
    set readonly
    set nomodified
endfunction " }}}


function vimelixirprofiler#setProfilerSortCommands() " {{{
    command! -bang -nargs=1 -buffer ExProfilerSort call vimelixirprofiler#sortByColumn('<bang>', '<args>')

    map <silent> <buffer> <Leader>f  :ExProfilerSort  0<CR>
    map <silent> <buffer> <Leader>rf :ExProfilerSort! 0<CR>

    map <silent> <buffer> <Leader>c  :ExProfilerSort  1<CR>
    map <silent> <buffer> <Leader>rc :ExProfilerSort! 1<CR>

    map <silent> <buffer> <Leader>%  :ExProfilerSort  2<CR>
    map <silent> <buffer> <Leader>r% :ExProfilerSort! 2<CR>

    map <silent> <buffer> <Leader>t  :ExProfilerSort  3<CR>
    map <silent> <buffer> <Leader>rt :ExProfilerSort! 3<CR>

    map <silent> <buffer> <Leader>u  :ExProfilerSort  4<CR>
    map <silent> <buffer> <Leader>ru :ExProfilerSort! 4<CR>
endfunction " }}}

function! s:parseLine(line) " {{{
    let matches = matchlist(a:line, s:PARSE_EPROF_LINE)
    if len(matches) < 6
        return []
    endif

    "let [ funName, calls, percentage, time, usecs_per_call ] = matches[1:6]
    return matches[1:5]
endfunction " }}}

function! s:translateErlangNameToElixir(name) " {{{
    let [module, funName, arity] = matchlist(a:name, s:PARSE_FUN_NAME)[1:3]

    if module =~# "^[a-z]"
        let module = ":" . module
    elseif module =~# "^'Elixir\."
        let module = substitute(module, "^'Elixir\.", "", "")
        let module = substitute(module, "'$", "", "")
    endif

    if funName =~# "^'.*'$"
        let funName = substitute(funName, "^'", "", "")
        let funName = substitute(funName, "'$", "", "")
    end

    return module . "·" . funName . "/" . arity
endfunction " }}}

function! s:setGlobal(name, default) " {{{
  if !exists(a:name)
    if type(a:name) == 0 || type(a:name) == 5
      exec "let " . a:name . " = " . a:default
    elseif type(a:name) == 1
      exec "let " . a:name . " = '" . escape(a:default, "\'") . "'"
    endif
  endif
endfunction " }}}

" vim: set sw=4 sts=4 et fdm=marker:
"
