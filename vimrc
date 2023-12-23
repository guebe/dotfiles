" press 'K' on any of the word under cursor to get help

colorscheme torte
filetype plugin indent on
packadd! matchit
set background=dark
set expandtab
set guifont=Monospace\ 14
set hidden
set hlsearch
set ignorecase
set incsearch
set mouse=a
set shiftwidth=4
set smartcase
set softtabstop=4
set termguicolors
syntax on
set wildmenu
set scrolloff=1
set sidescroll=1
set sidescrolloff=2
set display+=truncate
set formatoptions+=j

" jump to last position - from :h restore-cursor
autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif
