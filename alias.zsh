# anti-dumb
alias rm='rm -i'

# ls
alias la='ls -lAh'
alias ll='ls -lh'
alias l.='ls -ld .*'

# lazygit
alias lg="lazygit"

# tmux
alias tmux='tmux -2'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# Data Science project template: cookiecutter
alias makecookie='cookiecutter https://github.com/mparada/cookiecutter-data-science'
alias makecookiesimple='cookiecutter https://github.com/mparada/cookiecutter-data-science-simplified'

# monitor nvidia GPU
alias ntop='watch -n 1 nvidia-smi'

# xclip to clipboard
alias xc='xclip -selection clipboard'
