filetype on
filetype plugin on
filetype indent on

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

"-------------------------------------------------------------------------------
if has ('win32')
	set backspace=2
endif

"-------------------------------------------------------------------------------
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
    let l:left = col(".")
    let l:left_char = getline(".")[l:left - 2]
    if index(["(", "[", "{"], l:left_char) == -1
        return "\<BS>"
    endif

    let l:left_line = line(".")
    execute "normal! \<LEFT>%"
    let l:right_line = line(".")
    if l:left_line != l:right_line
        execute "normal %"
    endif
    let l:right = col(".")
    let l:distance = l:right - l:left
    if l:distance == -1
        return "\<RIGHT>\<BS>"
    elseif l:distance == 0
        return "\<RIGHT>\<BS>\<BS>"
    else
        return "\<RIGHT>\<BS>\<ESC>".l:distance."\<LEFT>a\<BS>"
    endif
endf

func! BackspaceReplace()
    :inoremap <BS> <c-r>=RemoveBrackets()<CR>
endf

func! ReturnInBrackets()
    let l:pos = col(".")
    let l:line = getline(".")
    if l:line[l:pos - 2] == "{" && l:line[l:pos - 1] == "}"
        return "\<RETURN>\<BS>\<RETURN>\<UP>\<TAB>"
    else
        return "\<RETURN>"
    endif
endf

func! ReturnReplace()
    :inoremap <RETURN> <c-r>=ReturnInBrackets()<CR>
endf

func! LineLength()
    if exists('+colorcolumn')
        set colorcolumn=80
    else
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        match OverLength /\%80v.\+/
    endif
endf

au FileType php,javascript,java,c,cpp,python,vim,sh exe InputBrackets()
au FileType php,javascript,java,c,cpp,python,vim,sh exe BackspaceReplace()
au FileType javascript,java,c,cpp,sh exe ReturnReplace()

au FileType php,javascript,java,c,cpp,python,vim,sh exe LineLength()
au FileType javascript,python,vim,sh set expandtab

"-------------------------------------------------------------------------------
func! CompileC()
    if has ('win32')
        :nnoremap <F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
\               shellescape('%:r.exe')<CR>
        :nnoremap <S-F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
\               shellescape('%:r.exe').' && '.shellescape('%:r.exe')<CR>
    else
        :nnoremap <F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
\               shellescape('%:r')<CR>
        :nnoremap <S-F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
\               shellescape('%:r').' && ./'.shellescape('%:r')<CR>
    endif
endf

func! CompileCPP()
    if has ('win32')
        rd
        :nnoremap <F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
\               ' -o '.shellescape('%:r.exe')<CR>
        :nnoremap <S-F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
\               ' -o '.shellescape('%:r.exe').' && '.shellescape('%:r.exe')
\               <CR>
    else
        :nnoremap <F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
\               ' -o '.shellescape('%:r')<CR>
        :nnoremap <S-F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
\               ' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
    endif
endf

func! RunPython()
    :nnoremap <F9> :w<bar>exec '!python '.shellescape('%')<CR>
endf

func! CtagsGenerate()
    :nnoremap <S-F12> :!ctags -R –c++-kinds=+px –fields=+iaS –extra=+q .<CR>  
endf

au FileType c exe CompileC()
au FileType cpp exe CompileCPP()
au FileType python exe RunPython()
au FileType c,cpp,python,java,vim,sh exe CtagsGenerate()

"-------------------------------------------------------------------------------
func! WordSearch()
    let l:before = col('.')
    execute "normal! *N"
    let l:after = col('.')
    if l:before > l:after
        return "\<ESC>*N".(l:before-l:after)."\<RIGHT>"
    else
        return "\<ESC>*N"
    endif
endf

func! StarReplace()
    :nnoremap * i<c-r>=WordSearch()<CR>
endf

exe StarReplace()

"-------------------------------------------------------------------------------
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
