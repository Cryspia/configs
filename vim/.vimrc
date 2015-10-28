filetype indent plugin on
syntax on

let mapleader = '\'

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
au FileType javascript,java,c,cpp,python,vim,sh set expandtab

"-------------------------------------------------------------------------------
"GUI settings
if has ('gui_running')
    set cursorline
    set tabpagemax=9
    set showtabline=2
    set lines=25
    set columns=86
    colorscheme darkblue
    if has('gui_gtk2')
        set guifont=DejaVu\ Sans\ Mono\ 12
    elseif has('gui_win32')
        set guifont=courier_new:h12
    endif
endif

"-------------------------------------------------------------------------------
"Windows backspace fix
if has ('win32')
	set backspace=2
endif

"-------------------------------------------------------------------------------
"Current word yank
nnoremap <leader>y viwy

"-------------------------------------------------------------------------------
"No-yanking cut
func! NoYankPaste(prefix)
    let l:beof = line('$')
    let l:blne = line("'<")
    let l:bpos = col("'<")
    let l:elne = line("'>")
    let l:epos = col("'>")
    let l:elen = strlen(getline("'>"))
    normal! gv"_d
    let l:aeof = line('$')
    let l:apos = col('.')
    let l:len = strlen(getline('.'))
    if (l:blne != l:elne) && (l:bpos > 1) && (l:epos != l:elen) &&
                \(visualmode() != "\<c-v>")
        execute "normal! i\<RETURN>\<ESC>\<UP>"
        let l:ulen = strlen(getline('.'))
        execute "normal! \<DOWN>0"
        let l:dlen = strlen(getline('.'))
        let l:diff = l:ulen + l:dlen - l:len
        if l:diff == 1
            normal! v"_d
        elseif l:diff > 1
            execute "normal! v".(l:diff - 1)."\<RIGHT>\"_d"
        endif
        execute 'normal! '.a:prefix.'P'
    elseif (l:beof == l:aeof && l:apos == l:len && l:bpos > l:apos) ||
                \(l:beof > l:aeof && l:apos == l:len && l:len > 1) ||
                \(l:beof > l:aeof && l:blne > l:aeof)
        normal! p
    else
        execute 'normal! '.a:prefix.'P'
    endif
endf

vnoremap <leader>x "_x
vnoremap <leader>X "_X
nnoremap <leader>x "_x
nnoremap <leader>X "_X
vnoremap <leader>d "_d
vnoremap <leader>D "_D
nnoremap <leader>d "_d
nnoremap <leader>D "_D
vnoremap <silent> <leader>p :<c-u>call NoYankPaste('')<CR>
nnoremap <silent> <leader>p viw:<c-u>call NoYankPaste('')<CR>
vnoremap <silent> <leader>gp :<c-u>call NoYankPaste('g')<CR>
nnoremap <silent> <leader>gp viw:<c-u>call NoYankPaste('g')<CR>

"-------------------------------------------------------------------------------
"Brackets matching
func! CloseBracket(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<RIGHT>"
    else
        return a:char
    endif
endf

func! CompleteBracket(char, shift)
    let l:this = getline('.')[col('.') - 1]
    let l:prev = getline('.')[col('.') - 3 + a:shift]
    let l:num = char2nr(l:this)
    if (l:num >= 48 && l:num <= 57) || (l:num >= 65 && l:num <= 90) || (l:num >= 96 && l:num <= 122) || l:this =='{' || l:this == '[' || l:this == '(' || l:this == '"' || l:this == "'" || l:this == '`' || (col('.') > 2-a:shift && l:prev == '\')
        return ''
    else
        return a:char."\<LEFT>"
    endif
endf

func! CloseQuota(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<RIGHT>"
    else
        return a:char.CompleteBracket(a:char, 1)
    endif
endf

func! InputBrackets()
    inoremap ( (<c-r>=CompleteBracket(')', 0)<CR>
    inoremap { {<c-r>=CompleteBracket('}', 0)<CR>
    inoremap [ [<c-r>=CompleteBracket(']', 0)<CR>
    inoremap ) <c-r>=CloseBracket(')')<CR>
    inoremap } <c-r>=CloseBracket('}')<CR>
    inoremap ] <c-r>=CloseBracket(']')<CR>
    inoremap ' <c-r>=CloseQuota("'")<CR>
    inoremap " <c-r>=CloseQuota('"')<CR>
endf

func! RemoveMatch()
    let l:left = col('.')
    let l:left_char = getline('.')[l:left - 2]
    let l:right_char = getline('.')[l:left - 1]
    if index(['(', '[', '{'], l:left_char) != -1
        let l:left_line = line('.')
        execute "normal! \<LEFT>%"
        let l:right_line = line('.')
        if l:left_line != l:right_line
            normal %
        endif
        let l:right = col('.')
        let l:distance = l:right - l:left
        if l:distance == -1
            return "\<RIGHT>\<BS>"
        elseif l:distance == 0
            return "\<RIGHT>\<BS>\<BS>"
        else
            return "\<RIGHT>\<BS>\<ESC>".l:distance."\<LEFT>a\<BS>"
        endif
    elseif l:left_char == l:right_char && index(['"', "'"], l:left_char) != -1
        return "\<RIGHT>\<BS>\<BS>"
    else
        return "\<BS>"
    endif
endf

func! BackspaceReplace()
    inoremap <BS> <c-r>=RemoveMatch()<CR>
endf

func! ReturnInBrackets()
    let l:pos = col('.')
    let l:line = getline('.')
    if l:line[l:pos - 2] == '{' && l:line[l:pos - 1] == '}'
        return "\<RETURN>\<RETURN>\<UP>\<TAB>"
    else
        return "\<RETURN>"
    endif
endf

func! ReturnReplace()
    inoremap <RETURN> <c-r>=ReturnInBrackets()<CR>
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
if has ('win32')
    let g:cpe = '.exe'
    let g:dirPrefix = ''
else
    let g:cpe = ''
    let g:dirPrefix = './'
endif

func! CompileC()
    let g:cpb = '-Wall -o'
    let g:cpa = ''
    nnoremap <F9> :w<bar>exec '!gcc '.g:cpb.' '.shellescape('%:r'.g:cpe).' '.
                \shellescape('%').' '.g:cpa<CR>
    nnoremap <F10> :w<bar>exec '!gcc '.g:cpb.' '.shellescape('%:r'.g:gpe).
                \' '.shellescape('%').' '.g:cpa.' && '.g:dirPrefix.
                \shellescape('%:r'.g:cpe)<CR>
endf

func! CompileCPP()
    let g:cpb = '-Wall -o'
    let g:cpa = ''
    nnoremap <F9> :w<bar>exec '!g++ --std=c++11 '.g:cpb.' '.
                \shellescape('%:r'.g:cpe).' '.shellescape('%').' '.g:cpa<CR>
    nnoremap <F10> :w<bar>exec '!g++ --std=c++11 '.g:cpb.' '.
                \shellescape('%:r'.g:cpe).' '.shellescape('%').' '.g:cpa.
                \' && '.g:dirPrefix.shellescape('%:r'.g:cpe)<CR>
endf

func! RunPython()
    nnoremap <F9> :w<bar>exec '!python '.shellescape('%')<CR>
    nnoremap <F10> :w<bar>exec '!python3 '.shellescape('%')<CR>
endf

func! CtagsGenerate()
    nnoremap <F12> :w<bar>:!ctags -R --c++-kinds=+px --fields=+iaS --extra=+q .<CR>
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
    execute "normal! ".l:l_before.'G'
    let l:c_after = col('.')
    let l:diff = l:c_before - l:c_after
    if l:diff > 0
        execute "normal! ".l:diff."\<RIGHT>"
        return "\<ESC>/".l:search."\<RETURN>".l:top.'zt'.l:l_before.'G'.
                    \l:diff."\<RIGHT>"
    else
        return "\<ESC>/".l:search."\<RETURN>".l:top.'zt'.l:l_before.'G'
    endif
endf

nnoremap <leader>s i<c-r>=WordSearch(0)<CR>
vnoremap <leader>s "myi<c-r>=WordSearch(1)<CR>
nnoremap <leader>r :%s/\<<c-r><c-w>\>//gc<Left><Left><Left>
vnoremap <leader>r "my:%s/<c-r>m//gc<Left><Left><Left>

"-------------------------------------------------------------------------------
"Force indent
func! ForceIndent()
    let l:pos = col('.')
    let l:return = ""
    if l:pos > strlen(getline('.'))
        let l:return = "\<RIGHT>"
    endif
    normal ^
    let l:head = col('.')
    let l:pos = l:pos - l:head
    if (l:pos < 0)
        let l:pos = 0
    endif
    if l:head != 1
        execute "normal! \<LEFT>v0\"_d"
    endif
    execute "normal \<UP>"
    let l:line = getline('.')
    execute "normal \<DOWN>"
    let l:i = 0
    while (l:line[l:i] == ' ') || (l:line[l:i] == "\<TAB>")
        execute "normal! i".l:line[l:i]."\<ESC>\<RIGHT>"
        let l:i += 1
    endwhile
    if (strlen(l:line) > 0)
        execute "normal! i\<TAB>\<ESC>\<RIGHT>"
    endif
    if (l:pos > 0)
        execute "normal! ".l:pos."\<RIGHT>"
    endif
    return l:return
endf

nnoremap <silent> <S-TAB> :call ForceIndent()<CR>
inoremap <S-TAB> <c-r>=ForceIndent()<CR>

"-------------------------------------------------------------------------------
"Mark out EOL whitespace
highlight WhitespaceEOL ctermbg=blue ctermfg=blue guibg=#66ccff
match WhitespaceEOL /\s\+$/

"-------------------------------------------------------------------------------
"Add special library tags
func! TagsDetection()
    let l:fileName = "~/.vim/".&filetype.".tags"
    if filereadable(glob(l:fileName))
        execute "set tags+=".l:fileName
    endif
endf

au FileType cpp exe TagsDetection()
set tags+=./../tags,./../../tags,./../../../tags,./../../../../tags

"-------------------------------------------------------------------------------
"Move UP/DOWN in a long line
func! LongLineMove(char)
    if &wrap
        return "g".a:char
    else
        return a:char
    endif
endf
onoremap <silent> <expr> j LongLineMove("j")
onoremap <silent> <expr> k LongLineMove("k")
onoremap <silent> <expr> <UP> LongLineMove("\<UP>")
onoremap <silent> <expr> <DOWN> LongLineMove("\<DOWN>")
nnoremap <silent> <expr> j LongLineMove("j")
nnoremap <silent> <expr> k LongLineMove("k")
nnoremap <silent> <expr> <UP> LongLineMove("\<UP>")
nnoremap <silent> <expr> <DOWN> LongLineMove("\<DOWN>")
inoremap <Up> <C-o>g<Up>
inoremap <Down> <C-o>g<Down>

"-------------------------------------------------------------------------------
"Keep selection after shift indent
vnoremap < <gv
vnoremap > >gv
