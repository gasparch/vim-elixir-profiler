if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" syncing starts 2000 lines before top line so docstrings don't screw things up
syn sync minlines=2000


"syn cluster eprofHeader contains=eprofHeaderDefinition
" elixirTodo,elixirArguments,elixirBlockDefinition,elixirUnusedVariable,elixirStructDelimiter



" Highlight header
syn match eprofHeaderDefinition /^\CFUNCTION\s*CALLS.*uS.*CALLS.*$/
syn match eprofHeaderDefinition /\%2l.*$/

syn match eprofFooterDefinition /^-\{10,\}.*$/
syn match eprofFooterDefinition /^Total:\s\+\d\+\s\+100.00%.*$/


syntax match eprofModuleDot "·" conceal cchar=.
syntax match eprofModuleName "^\S\+·\@="



"syn region elixirStruct matchgroup=elixirStructDelimiter start="%\(\w\+{\)\@=" end="}" contains=ALLBUT,@elixirNotTop


hi def link eprofHeaderDefinition Special
hi def link eprofFooterDefinition Special
hi def link eprofModuleName Type

let b:current_syntax = "elixir-eprof"

let &cpo = s:cpo_save
unlet s:cpo_save
