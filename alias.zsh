# anti-dumb
alias rm='rm -i'

# ls
alias l='ls -lah'

# git
alias gg='git status -s'

# tmux
alias tmux='tmux -2'
alias ta='tmux -CC attach -t'
alias tnew='tmux -CC new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# Data Science project template: cookiecutter
alias makecookie='cookiecutter https://github.com/mparada/cookiecutter-data-science'
alias makecookiesimple='cookiecutter https://github.com/mparada/cookiecutter-data-science-simplified'

# monitor nvidia GPU
alias ntop='watch -n 1 nvidia-smi'
