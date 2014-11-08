filetype indent plugin on
syntax on

let mapleader = "\\"

set nu
set ruler

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

set mouse=a

set tabstop=4
set smarttab
set shiftwidth=4
set softtabstop=4
au FileType javascript,python,vim,sh set expandtab

"-------------------------------------------------------------------------------
"GUI settings
if has ('gui_running')
    set cursorline
    set tabpagemax=9
    set showtabline=2
    set lines=25
    set columns=86
    colorscheme darkblue
    if has("gui_gtk2")
        set guifont=DejaVu\ Sans\ Mono\ 12
    elseif has("gui_win32")
        set guifont=courier_new:h12
    endif
endif

"-------------------------------------------------------------------------------
"Windows backspace fix
if has ('win32')
	set backspace=2
endif

"-------------------------------------------------------------------------------
"No-yanking cut
vnoremap <leader>x "_x
vnoremap <leader>X "_X
vnoremap <leader>d "_d
vnoremap <leader>D "_D
vnoremap <leader>p "_dp
vnoremap <leader>P "_dP

"-------------------------------------------------------------------------------
"Brackets matching
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
        return "\<RETURN>\<RETURN>\<UP>\<TAB>"
    else
        return "\<RETURN>"
    endif
endf

func! ReturnReplace()
    :inoremap <RETURN> <c-r>=ReturnInBrackets()<CR>
endf

au FileType php,javascript,java,c,cpp,python,vim,sh exe InputBrackets()
au FileType php,javascript,java,c,cpp,python,vim,sh exe BackspaceReplace()
au FileType javascript,java,c,cpp,sh exe ReturnReplace()


"-------------------------------------------------------------------------------
"Mark 80th column
func! LineLength()
    if exists('+colorcolumn')
        set colorcolumn=80
    else
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        match OverLength /\%80v.\+/
    endif
endf

au FileType php,javascript,java,c,cpp,python,vim,sh exe LineLength()

"-------------------------------------------------------------------------------
"Compiler/ctags call
func! CompileC()
    if has ('win32')
        :nnoremap <F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
                    \shellescape('%:r.exe')<CR>
        :nnoremap <S-F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
                    \shellescape('%:r.exe').' && '.shellescape('%:r.exe')<CR>
    else
        :nnoremap <F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
                    \shellescape('%:r')<CR>
        :nnoremap <S-F9> :w<bar>exec '!gcc -Wall '.shellescape('%').' -o '.
                    \shellescape('%:r').' && ./'.shellescape('%:r')<CR>
    endif
endf

func! CompileCPP()
    if has ('win32')
        :nnoremap <F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
                    \' -o '.shellescape('%:r.exe')<CR>
        :nnoremap <S-F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
                    \' -o '.shellescape('%:r.exe').' && '.shellescape('%:r.exe')
                    \<CR>
    else
        :nnoremap <F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
                    \' -o '.shellescape('%:r')<CR>
        :nnoremap <S-F9> :w<bar>exec '!g++ --std=c++11 -Wall '.shellescape('%').
                    \' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
    endif
endf

func! RunPython()
    :nnoremap <F9> :w<bar>exec '!python '.shellescape('%')<CR>
endf

func! CtagsGenerate()
    :nnoremap <S-F12> :w<bar>:!ctags -R --c++-kinds=+px --fields=+iaS --extra=+q .<CR>
endf

au FileType c exe CompileC()
au FileType cpp exe CompileCPP()
au FileType python exe RunPython()
au FileType c,cpp,python,java,vim,sh exe CtagsGenerate()

"-------------------------------------------------------------------------------
"Current word search/replace
func! WordSearch(type)
    if a:type == 0
        let l:search = "\\\<\<c-r>\<c-w>\\\>"
    else
        let l:search = "\<c-r>m"
    endif
    let l:c_before = col('.')
    let l:l_before = line('.')
    let l:top = line('w0')
    execute "normal! ".l:l_before."G"
    let l:c_after = col('.')
    let l:diff = l:c_before - l:c_after
    if l:diff > 0
        execute "normal! ".l:diff."\<RIGHT>"
        return "\<ESC>/".l:search."\<RETURN>".l:top."zt".l:l_before."G".
                    \l:diff."\<RIGHT>"
    else
        return "\<ESC>/".l:search."\<RETURN>".l:top."zt".l:l_before."G"
    endif
endf

:nnoremap <leader>s i<c-r>=WordSearch(0)<CR>
:vnoremap <leader>s "myi<c-r>=WordSearch(1)<CR>
:nnoremap <leader>r :%s/\<<c-r><c-w>\>//gc<Left><Left><Left>
:vnoremap <leader>r "my:%s/<c-r>m//gc<Left><Left><Left>

"-------------------------------------------------------------------------------
"Mark out EOL whitespace
highlight WhitespaceEOL ctermbg=blue ctermfg=blue guibg=#66ccff
match WhitespaceEOL /\s\+$/
