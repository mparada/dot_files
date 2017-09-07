set langmenu=en_US.UTF-8 "menu language
let $LANG = 'en'         "messages/ui language

call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

set tabstop=4
set shiftwidth=4
set expandtab
set number

" for clipboard access in tmux, needs reattach-to-user-namespace
set clipboard=unnamed
