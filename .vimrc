:set nu 
:set smartindent
:set showmatch
:set ai
:set ts=4
:syntax on
:set backspace=start,indent,eol
:set wrapscan
:set t_Co=256
:colo gardener 
set path+=$PWD/**

python << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
map <silent><C-Left> <C-T>
map <silent><C-Right> <C-]>
autocmd FileType python set omnifunc=pythoncomplete#Complete
inoremap <Nul> <C-x><C-o>
