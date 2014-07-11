set nu
set ruler
set rulerformat = %15(%c%V\ %p%%%)
set tabstop=4
set expandtab
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
set tabpagemax = 9
set showtabline = 2
set hlsearch
set magic
set showmatch
set mouse = a

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

au FileType php,javascript,java,c,cpp,python exe AutoClose()
au FileType php,javascript,java,c,cpp,python exe MatchingQuotes()

if has ('gui_running')
	set cursorline
endif