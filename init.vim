set langmenu=en_US.UTF-8 "menu language
let $LANG = 'en'         "messages/ui language

" vim-plug to install plugins
" :PlugInstall
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-surround'
Plug 'nvie/vim-flake8'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/rainbow_parentheses.vim'

call plug#end()

" general settings
set tabstop=4
set shiftwidth=4
set expandtab
set gdefault
set wrap
set textwidth=79

" relative numbers in normal mode
" absolute numbers in insert mode
set number relativenumber
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" mouse support
set mouse=a

" for clipboard access in tmux, needs reattach-to-user-namespace
set clipboard=unnamed

" python interpreters for neovim
" note: neovim should be run inside p3neovim env
let g:python_host_prog = '/Users/mpr/anaconda/envs/py2neovim/bin/python'
let g:python3_host_prog = '/Users/mpr/anaconda/bin/python'

" autocomplete with deoplete
let g:deoplete#enable_at_startup = 1
set completeopt-=preview " do not open scratch/preview window
" tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" easily toggle rainbow_parentheses
:nnoremap <leader>R :RainbowParentheses!!<enter>

" fuzzy file search shortcut
:nnoremap <C-p> :FZF<enter>
