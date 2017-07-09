# vim-elixir-profiler

This is a part of [Vim-Elixir-IDE](https://github.com/gasparch/vim-ide-elixir) package.

Provides better navigation for eprof profiling output.

 - translates module/function names to Elixir convention
 - highligh module names
 - sort output based on every columns on fly


# Installation

Drop the file in ~/.vim/plugin or ~/vimfiles/plugin folder, or if you
use pathogen into the ~/.vim/bundle/vim-elixir-profiler or
~/vimfiles/bundle/vim-elixir-profiler.

# Usage

Open file with extension `.eprof` and it will be automatically detected as
eprof output and highlighted properly.


# Keyboard shortcuts

Plugin provides extra shortcuts to sort content of eprof file.

* `<Leader>f`  - sort based on function name
* `<Leader>rf` - reverse sort on function name
* `<Leader>c`  - sort based on call count
* `<Leader>rc` - reverse sort on call count
* `<Leader>%`  - sort based on percent of total time spent in the function
* `<Leader>r%` - reverse sort based on percent of time
* `<Leader>t`  - sort based on total time spent in the function
* `<Leader>rt` - reverse sort based on total time
* `<Leader>u`  - sort based on usec/call 
* `<Leader>ru` - reverse sort based on usec/call

## TODO

 - Add jump to module/preview functionality

