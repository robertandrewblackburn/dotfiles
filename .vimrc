" rab's .vimrc
" slowly building up from scratch

set nocompatible " don't worry about vi compatibility

""""""""""""""""""""""""""""""
" Table of Contents
" ----------------------------
" 0. Basic Interface and Behavior
" 1. Indentation
" 2. File Support and Theming
" 3. Searching
" 4. Keys & Custom Commands
"


""""""""""""""""""""""""""""""
" 0. Basic Interface and Behaviour

set title " use buffer name as terminal title
set showcmd " show partially complete vim commands
set cmdheight=2 " set the command window height to two lines

set number " show line numbers
set wrap " wrap long lines

set showtabline=2 " always show tabs at top of window

set ruler " show cursor position in bottom-right
set cursorline " underline the current line
set scrolloff=5 " start scrolling the buffer when 5 lines from the edge

set autoread " if a file is changed outside of vim, autoreload the buffer
set lazyredraw " don't redraw while executing macros to save on perf
set hidden " let you switch from an unsaved buffers without being prompted to save (gets hidden in the background instead)


""""""""""""""""""""""""""""""
" 1. Indentation """""""""""""

" let's try out the 'standard' indentation (ie 4 spaces instead of tabs)
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4


""""""""""""""""""""""""""""""
" 2. File Support & Theming ""
syntax enable " enable syntax highlighting
filetype plugin indent on " enable the (netrw) filetype plugin and indent detection

" Things that should already exist/are slightly tweaked from the newer defaults.vim
set backspace=indent,eol,start " backspace works normally in INSERT mode
set history=5000 "more undo history


""""""""""""""""""""""""""""""
" 3. Searching """""""""""""""

set wildmenu " display completion matches in a status line
set incsearch " enable incremental searching as you type
set hlsearch " highlight search results
if maparg('C-L', 'n') ==# '' " use <C-L> to clear the highlighting from hlsearch (from sensible.vim)
    nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
set ignorecase " case insensitive searching...
set smartcase " unless you're typing caps on purpose
set complete-=i " autocomplete suggestions from all linked files


""""""""""""""""""""""""""""""
" 4. Keys & Custom Commands ""

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif " Return to last edit position when opening files

command! W execute 'w !sudo tee % > /dev/null' <bar> edit! " :W to sudo save a file

""""""""""""""""""""""""""""""

