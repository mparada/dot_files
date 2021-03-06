set langmenu=en_US.UTF-8 "menu language
let $LANG = 'en'         "messages/ui language

" detect OS for OS specific commands
let uname = substitute(system('uname'), '\n', '', '')
" Example values: Linux, Darwin, MINGW64_NT-10.0, MINGW32_NT-6.1

" vim-plug to install plugins
" :PlugInstall
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-surround'
Plug 'nvie/vim-flake8'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
if uname == 'Darwin'
    Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
elseif uname == 'Linux'
    Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
endif
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'iamcco/markdown-preview.vim'

call plug#end()

" general settings
set tabstop=4
set shiftwidth=4
set expandtab
set gdefault
let &colorcolumn="80,".join(range(120,999),",")
highlight ColorColumn ctermbg=237 guibg=237

" file type specif settings
autocmd bufreadpre *.md setlocal textwidth=80

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

" for clipboard access outside nvim
" for tmux in OSX reattach-to-user-namespace is needed
set clipboard^=unnamed,unnamedplus

" python interpreters for neovim
" note: run pip2 install --user neovim && pip3 install --user neovim
let g:python_host_prog = substitute(system('which python2'), '\n', '', '')
let g:python3_host_prog = substitute(system('which python3'), '\n', '', '')

" autocomplete with deoplete
let g:deoplete#enable_at_startup = 1
set completeopt-=preview " do not open scratch/preview window
" tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" easily toggle rainbow_parentheses
:nnoremap <leader>R :RainbowParentheses!!<enter>

" fuzzy file search shortcut
:nnoremap <C-p> :FZF<enter>

" set up for markdown-preview
let g:mkdp_path_to_chrome = "open -a Google\\ Chrome"
