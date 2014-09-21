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

func! CloseBracket(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<RIGHT>"
    else
        return a:char
    endif
endf

func! InputBrackets()
    :inoremap ( ()<LEFT>
    :inoremap { {}<LEFT>
    :inoremap [ []<LEFT>
    :inoremap ) <c-r>=CloseBracket(')')<CR>
    :inoremap } <c-r>=CloseBracket('}')<CR>
    :inoremap ] <c-r>=CloseBracket(']')<CR>
endf

func! RemoveBrackets()
    let l:line = getline(".")
    let l:left = col(".")
    let l:left_char = l:line[l:left - 1]

    if index(["(", "[", "{"], l:left_char) != -1
        execute "normal %"
        let l:right = col(".")
        let l:distance = l:right - l:left - 1

        if l:distance == -1
            execute "normal! a\<BS>"
        elseif l:distance == 0
            execute "normal! a\<BS>\<BS>"
        else
            execute "normal! a\<BS>\<ESC>".l:distance."\<LEFT>a\<BS>"
        endif
    else
        execute "normal! a\<BS>"
    end
endf

func! BackspaceReplace()
    :inoremap <BS> <ESC>:call RemoveBrackets()<CR>a
endf

func! LineLength()
    if exists('+colorcolumn')
        set colorcolumn=80
    else
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        match OverLength /\%>79v.\+/
    endif
endf

au FileType php,javascript,java,c,cpp,python,vim exe InputBrackets()
au FileType php,javascript,java,c,cpp,python,vim exe BackspaceReplace()
au FileType php,javascript,java,c,cpp,python,vim exe LineLength()
au FileType javascript,python,vim set expandtab

if has ('gui_running')
    set mouse=a
    set cursorline
    set tabpagemax=9
    set showtabline=2
    set lines=25
    set columns=86
    colorscheme darkblue
    if has("gui_gtk2")
        set guifont=DejaVu\ Sans\ Mono\ 18
    elseif has("gui_win32")
        set guifont=courier_new:h12
    endif
endif
