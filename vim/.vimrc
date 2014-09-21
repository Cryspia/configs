set nu
set ruler
set tabstop=4
set smarttab
set shiftwidth=4
set softtabstop=4
set nobackup
set noswapfile
set nowritebackup
set autoindent
set smartindent
set complete=.,w,b,k,t,i
set completeopt=longest,menu
set hlsearch
set magic
set showmatch
syntax on

func! MatchingQuotes()
    inoremap ( ()<left>
    inoremap [ []<left>
    inoremap { {}<left>
    inoremap " ""<left>
    inoremap ' ''<left>
endf

func! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf

func! AutoClose()
    :inoremap ( ()<ESC>i
    :inoremap " ""<ESC>i
    :inoremap ' ''<ESC>i
    :inoremap { {}<ESC>i
    :inoremap [ []<ESC>i
    :inoremap ) <c-r>=ClosePair(')')<CR>
    :inoremap } <c-r>=ClosePair('}')<CR>
    :inoremap ] <c-r>=ClosePair(']')<CR>
endf

func! LineLength()
    if exists('+colorcolumn')
        set colorcolumn=80
    else
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        match OverLength /\%>80v.\+/
    endif
endf

au FileType php,javascript,java,c,cpp,python,vim exe AutoClose()
au FileType php,javascript,java,c,cpp,python,vim exe MatchingQuotes()
au FileType php,javascript,java,c,cpp,python,vim exe LineLength()
au FileType javascript,python,vim set expandtab

if has ('gui_running')
    set mouse=a
    set cursorline
    set tabpagemax=9
    set showtabline=2
    set lines=25
    set columns=85
    colorscheme darkblue
    if has("gui_gtk2")
        set guifont=DejaVu\ Sans\ Mono\ 18
    elseif has("gui_win32")
        set guifont=courier_new:h12
    endif
endif
