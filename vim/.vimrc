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

set autoread
au WinEnter * filetype detect

"-------------------------------------------------------------------------------
"Unset old filetype keys and configs
func! UnsetAll()
    set expandtab!
    call LengthTab(4)
    let g:cmmark = '# '
    inoremap ( (
    inoremap { {
    inoremap [ [
    inoremap ) )
    inoremap } }
    inoremap ] ]
    inoremap ' '
    inoremap " "
    inoremap < <
    inoremap > >
    inoremap <BS> <BS>
    inoremap <RETURN> <RETURN>
    nnoremap <F9> <F9>
    nnoremap <F10> <F10>
    nnoremap <F12> <F12>
endf

au FileType * exe UnsetAll()

"-------------------------------------------------------------------------------
"Tab settings
set smarttab
au FileType javascript,html,xml,java,c,cpp,python,ocaml,vim,sh set expandtab

func! LengthTab(tabL)
    execute 'set tabstop='.a:tabL
    execute 'set shiftwidth='.a:tabL
    execute 'set softtabstop='.a:tabL
endf
au FileType javascript,html,xml,ocaml exe LengthTab(2)

func! AutoCompleteTab(cpl)
    let l:pos = col('.')
    let l:tc = getline('.')[l:pos - 2]
    let l:pc = getline('.')[l:pos - 3]
    let l:tn = char2nr(l:tc)
    let l:pn = char2nr(l:pc)
    if (97 <= l:tn && l:tn <= 122) || (65 <= l:tn && l:tn <= 90) ||
                \(48 <= l:tn && l:tn <= 57) || (l:tn == 36) || (l:tn == 46) ||
                \(l:tn == 95) || (l:pn == 45 && l:tn == 62) ||
                \(l:pn == 58 && l:tn == 58)
        return a:cpl
    endif
    return "\<TAB>"
endf

inoremap <TAB> <c-r>=AutoCompleteTab("\<c-p>")<CR>
au FileType ocaml inoremap <TAB> <c-r>=AutoCompleteTab("\<c-x>\<c-o>")<CR>

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
"Windows/Mac backspace fix
if has ('win32')
    set backspace=2
endif
if has ('unix')
    set backspace=indent,eol,start
endif

"-------------------------------------------------------------------------------
"Current word yank
nnoremap <leader>y viwy

"-------------------------------------------------------------------------------
"Not used any more. This function is too complicated and may cause strange act
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
"vnoremap <silent> <leader>p :<c-u>call NoYankPaste('')<CR>
"nnoremap <silent> <leader>p viw:<c-u>call NoYankPaste('')<CR>
"vnoremap <silent> <leader>gp :<c-u>call NoYankPaste('g')<CR>
"nnoremap <silent> <leader>gp viw:<c-u>call NoYankPaste('g')<CR>
vnoremap <silent> <leader>p pgvy
nnoremap <silent> <leader>p viwpgvy
vnoremap <silent> <leader>P Pgvy
nnoremap <silent> <leader>P viwPgvy

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
    let l:pos = col('.')
    let l:this = getline('.')[l:pos - 1]
    let l:prev = getline('.')[l:pos - 3 + a:shift]
    let l:num = char2nr(l:this)
    if ((l:num >= 48 && l:num <= 57) || (l:num >= 96 && l:num <= 122) ||
                \(l:num >= 65 && l:num <= 90) ||
                \index(['(', '[', '{', '"', "'", '`'], l:this) != -1 ||
                \(l:pos > 2-a:shift && l:prev == '\'))
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
endf

func! InputQuotas()
    inoremap ' <c-r>=CloseQuota("'")<CR>
    inoremap " <c-r>=CloseQuota('"')<CR>
endf

"Not used any more. This function can seldom be of use and is too slow.
func! OldRemoveMatch(mode)
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
    elseif (l:left_char == l:right_char && index(['"', "'"], l:left_char) != -1)
                \|| (a:mode == 1 && l:left_char == '<' && l:right_char == '>')
        return "\<RIGHT>\<BS>\<BS>"
    else
        return "\<BS>"
    endif
endf

func! RemoveMatch(mode)
    let l:pos = col('.')
    let l:lc = getline('.')[l:pos - 2]
    let l:rc = getline('.')[l:pos - 1]
    if (l:lc == '{' && l:rc == '}') || (l:lc == '(' && l:rc == ')')
                \|| (l:lc == '[' && l:rc == ']')
                \|| (l:lc == '"' && l:rc == '"')
                \|| (l:lc == "'" && l:rc == "'")
                \|| (a:mode == 1 && l:lc == '<' && l:rc == '>')
        return "\<RIGHT>\<BS>\<BS>"
    else
        return "\<BS>"
    endif
endf

func! BackspaceReplace()
    inoremap <BS> <c-r>=RemoveMatch(0)<CR>
endf

func! InputXMLgt()
    let l:pos = col('.')
    let l:line = getline('.')
    if l:line[l:pos - 1] != '>'
        return '>'
    endif
    if l:pos > 1 && index(['<', ' ', '/', '\\'], l:line[l:pos-2]) != -1
        return "\<RIGHT>"
    endif
    let l:ln = line('.')
    normal %
    let l:lpos = col('.')
    let l:num = char2nr(getline('.')[l:lpos])
    if (l:lpos == l:pos && l:ln == line('.')) || !((l:num >= 96 && l:num <= 122)
                \|| (l:num >= 65 && l:num <= 90)
                \|| (l:num >= 48 && l:num <= 57))
        normal %
        return '>'
    endif
    execute "normal! \<RIGHT>\<ESC>viw\"my".
                \l:lpos."|%a</>\<ESC>\<LEFT>\"mp".l:pos.'|'
    return "\<RIGHT>"
endf

func! MatchXML()
    exe InputBrackets()
    inoremap < <<c-r>=CompleteBracket('>', 0)<CR>
    inoremap > <c-r>=InputXMLgt()<CR>
    inoremap <BS> <c-r>=RemoveMatch(1)<CR>
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

func! ReturnAtEnd()
    let l:opos = col('.')
    let l:line = getline('.')
    let l:len = strlen(l:line)
    if l:opos <= l:len || l:len < 7
        return "\<RETURN>"
    endif
    let l:chk = strpart(l:line,0,6)
    let l:num = char2nr(l:line[6])
    if tolower(l:chk) != "\\begin" || (l:num >= 96 && l:num <= 122)
                \|| (l:num >= 65 && l:num <= 90)
                \|| (l:num >= 48 && l:num <= 57)
        return "\<RETURN>"
    endif
    execute "normal! \<ESC>7|v"
    if l:line[col('.')-1] != '{'
        normal! f{
    endif
    let l:pos = col('.')
    let l:ln = line('.')
    normal %
    if col('.') == l:pos || line('.') != l:ln
        normal %
        execute "normal! \<ESC>$"
        return "\<RIGHT>\<RETURN>"
    else
        execute "normal! \"myA\\end\<ESC>\"mp".l:opos.'|'
        return "\<RETURN>\<RETURN>\<UP>"
    endif
endf

func! MatchSection()
    inoremap <RETURN> <c-r>=ReturnAtEnd()<CR>
endf

au FileType php,javascript,java,c,cpp,python,ocaml,vim,sh,plaintex,context,tex
            \ exe InputBrackets()
au FileType php,javascript,java,c,cpp,python,ocaml,vim,sh
            \ exe InputQuotas()
au FileType php,javascript,java,c,cpp,python,ocaml,vim,sh,plaintex,context,tex
            \ exe BackspaceReplace()
au FileType html exe MatchXML()
au FileType javascript,java,c,cpp,sh exe ReturnReplace()
au FileType plaintex,context,tex exe MatchSection()

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

call LineLength()

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
    nnoremap <F10> :w<bar>exec '!gcc '.g:cpb.' '.shellescape('%:r'.g:cpe).
                \' '.shellescape('%').' '.g:cpa.' && '.g:dirPrefix.
                \shellescape('%:r'.g:cpe)<CR>
endf

func! CompileCPP()
    let g:cpb = '-Wall -o'
    let g:cpa = ''
    nnoremap <F9> :w<bar>exec '!g++ --std=c++14 '.g:cpb.' '.
                \shellescape('%:r'.g:cpe).' '.shellescape('%').' '.g:cpa<CR>
    nnoremap <F10> :w<bar>exec '!g++ --std=c++14 '.g:cpb.' '.
                \shellescape('%:r'.g:cpe).' '.shellescape('%').' '.g:cpa.
                \' && '.g:dirPrefix.shellescape('%:r'.g:cpe)<CR>
endf

func! CompileJava()
    let g:cpb = ''
    let g:cpa = ''
    let g:exb = ''
    let g:exa = ''
    nnoremap <F9> :w<bar>exec '!javac '.g:cpb.' '.shellescape('%').' '.g:cpa<CR>
    nnoremap <F10> :w<bar>exec '!javac '.g:cpb.' '.shellescape('%').' '.g:cpa.
                \' && java '.g:exb.' '.shellescape('%:r').' '.g:exa<CR>
endf

func! RunPython()
    nnoremap <F9> :w<bar>exec '!python '.shellescape('%')<CR>
    nnoremap <F10> :w<bar>exec '!python3 '.shellescape('%')<CR>
endf

func! CompileTEX()
    nnoremap <F9> :w<bar>exec '!xelatex -halt-on-error '.shellescape('%')<CR>
    nnoremap <F10> :w<bar>exec '!bibtex '.shellescape('%:r')<CR>
    nnoremap <F12> :w<bar>exec '!xelatex -halt-on-error '.shellescape('%').
                \' && '.'bibtex '.shellescape('%:r').
                \' && '.'xelatex -halt-on-error '.shellescape('%').
                \' && '.'xelatex -halt-on-error '.shellescape('%').
                \' && '.'rm -f '.shellescape('%:r').'.{log,blg,bbl,aux}'<CR>
endf

func! CtagsGenerate()
    nnoremap <F12> :w<bar>:!ctags -R --c++-kinds=+px --fields=+iaS --extra=+q .<CR>
endf

au FileType c exe CompileC()
au FileType cpp exe CompileCPP()
au FileType java exe CompileJava()
au FileType python exe RunPython()
au FileType tex exe CompileTEX()
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
"Comment / Uncomment target line(s)
au FileType c,cpp,java,javascript let g:cmmark = "//"
au FileType vim let g:cmmark = '"'
au FileType python,sh let g:cmmark = '#'
au FileType plaintex,context,tex let g:cmmark='%'

func! SingleLineComment()
    let l:pos = col('.')
    execute "normal! 0i".g:cmmark."\<ESC>".l:pos."\<RIGHT>"
endf

func! SingleLineUncomment(len)
    let l:pos = col('.') - a:len
    execute "normal! 0d".a:len."\<RIGHT>"
    if (l:pos > 1)
        execute "normal! ".(l:pos - 1)."\<RIGHT>"
    endif
endf

func! MultiLineComment(len)
    let l:blne = line("'<")
    let l:elne = line("'>")
    let l:line = line('.')
    let l:pos = col('.') + a:len - 1
    execute "normal! ".l:blne."G\<c-v>".l:elne."GI".g:cmmark."\<ESC>".
                \l:line."G".l:pos."\<RIGHT>"
endf

func! MultiLineUncomment(len)
    let l:blne = line("'<")
    let l:elne = line("'>")
    let l:line = line('.')
    let l:pos = col('.') - a:len - 1
    let l:offset = ''
    if (a:len > 1)
        let l:offset = (a:len - 1)."\<RIGHT>"
    endif
    execute "normal! ".l:blne."G\<c-v>".l:elne."G".l:offset.'"_d'.l:line.
                \"G"
    if (l:pos > 0)
        execute "normal! ".l:pos."\<RIGHT>"
    endif
endf

nnoremap <silent> <leader>= :call SingleLineComment()<CR>
nnoremap <silent> <leader>- :call SingleLineUncomment(strlen(g:cmmark))<CR>
vnoremap <silent> <leader>= :<c-u>call MultiLineComment(strlen(g:cmmark))<CR>
vnoremap <silent> <leader>- :<c-u>call MultiLineUncomment(strlen(g:cmmark))<CR>

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
vnoremap <silent> <expr> j LongLineMove("j")
vnoremap <silent> <expr> k LongLineMove("k")
vnoremap <silent> <expr> <UP> LongLineMove("\<UP>")
vnoremap <silent> <expr> <DOWN> LongLineMove("\<DOWN>")
inoremap <Up> <C-o>g<Up>
inoremap <Down> <C-o>g<Down>

"-------------------------------------------------------------------------------
"Keep selection after shift indent
vnoremap < <gv
vnoremap > >gv
