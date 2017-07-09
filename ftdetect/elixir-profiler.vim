" we recognize file type just by extension of the file
au BufReadPost *.eprof call s:read('eprof')
au BufReadPost *.fprof call s:read('fprof')

function! s:read(filetype) abort
  call vimelixirprofiler#boot(a:filetype)
  call vimelixirprofiler#read(a:filetype)
endfunction
