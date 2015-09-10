set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/vundle' 

Plugin 'skammer/vim-css-color'
Plugin 'pangloss/vim-javascript'
Plugin 'chrismetcalf/vim-json'
Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'kchmck/vim-coffee-script'
Plugin 'fholgado/minibufexpl.vim'
Plugin 'tpope/vim-surround'
Plugin 'Markdown'

call vundle#end()

filetype plugin indent on
:set wildmenu
:set nu 
":set smartindent
:set showmatch
:set ai
:set ts=4
:set sw=4 " treat 4 spaces as a tab when deleting
:set sts=4 " treat 4 spaces as a tab when deleting
:set expandtab " insert spaces instead of \t
:syntax on
:set backspace=start,indent,eol
:set wrapscan
:set t_Co=256
:colo railscasts
:set hidden
:set switchbuf=usetab,newtab " use an existing tab if one exists for a file, otherwise create a new one
let mapleader = ","
set path+=$PWD/**

" Commenting blocks of code.
autocmd FileType c,cpp,java,scala,js  let b:comment_leader = '// '
autocmd FileType sh,ruby,python,conf,coffe let b:comment_leader = '# '
autocmd FileType vim let b:comment_leader = '" '
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

let g:CommandTMaxHeight=20
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" Fast saving
nmap <leader>w :w!<cr>

" Fast editing of the .vimrc
map <leader>e :e! ~/.vimrc<cr>

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vimrc

set wildmenu "Turn on WiLd menu

set ruler "Always show current position

set cmdheight=1 "The commandbar height

set hid "Change buffer - without saving

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase "Ignore case when searching
set smartcase

set hlsearch "Highlight search things

set incsearch "Make search act like search in modern browsers
set nolazyredraw "Don't redraw while executing macros 

set magic "Set magic on, for regular expressions

set showmatch "Show matching bracets when text indicator is over them

set nobackup
set nowb
set noswapfile


" Set to auto read when a file is changed from the outside
set autoread

set nobackup
set nowb
set noswapfile

if has("gui_running")
  colo gardener
  if has("mac")
    set guifont=Menlo:h12
  endif
endif


"if has('python')
"    python << EOF
 "   import os
 "   import sys
    "import vim
    "for p in sys.path:
    "    if os.path.isdir(p):
    "        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
    "EOF
    "finish
"endif

map <silent><C-j> :bprev<cr>
map <silent><C-l> :bnext<cr>
map <silent><C-Down> :bd!<cr>
map <silent><C-Up> <C-^>
autocmd FileType python set omnifunc=pythoncomplete#Complete
inoremap <Nul> <C-x><C-o>

autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType markdown set nonumber
autocmd FileType markdown colorscheme morning

au FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
" You might also find this useful
"
au BufNewFile,BufRead *.{php,phpt,arb,rb} call PHPSettings()

"let g:phpErrorMarker#openQuickfix=0
"let g:phpErrorMarker#automake = 1

function! PHPSettings()
    :set ts=2
    :set sw=2 " treat 2 spaces as a tab when deleting2
    :set sts=2 " treat 2 spaces as a tab when deleting
    " highlight anything over 80 chars
    highlight OverLength ctermbg=darkred ctermfg=grey guibg=#FFD9D9 
    highlight Error ctermbg=darkred ctermfg=grey guibg=#FFD9D9 
    match OverLength /\%>80v.\+/
    let php_sql_query=1                                                                                        
    let php_htmlInStrings=1
endfunction

" Folding
" http://smartic.us/2009/04/06/code-folding-in-vim/
"set foldmethod=indent
"set foldnestmax=10
"set foldlevel=1
"set foldnestmax=2

" CTags config
let Tlist_Compact_Format = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Ctags_Cmd = "ctags"
let Tlist_WinWidth = 40
map <F4> :TlistToggle<cr>
map <F6> :NERDTreeToggle<cr>
map <F8> :!ctags .<CR>
map <F9> :syntax sync fromstart<CR>
" More ctags stuff: http://amix.dk/blog/post/19329 
" Generate ctags data for a PHP project: ctags-exuberant -f ~/.vim/mytags/mendeley -h ".php" -R --totals=yes --tag-relative=yes --PHP-kinds=+cf --regex-PHP='/abstract class ([^ ]*)/\1/c/' --regex-PHP='/interface ([^ ]*)/\1/c/' --regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'
