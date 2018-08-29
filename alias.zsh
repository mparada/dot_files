# anti-dumb
alias rm='rm -i'

# git
alias gg='git status -s'

# tmux
alias tmux='tmux -2'
alias ta='tmux -CC attach -t'
alias tnew='tmux -CC new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# DB connection
alias dbcon='pgcli -d D9SBX -p 5438 -h axonlu-dbsvr5.mappuls.int -U mpr'

# Data Science project template: cookiecutter
alias makecookie='cookiecutter https://github.com/mparada/cookiecutter-data-science'
alias makecookiesimple='cookiecutter https://github.com/mparada/cookiecutter-data-science-simplified'

# SSH tunnel to GPU Server's RStudio
alias gpu-rstudio='ssh -N -p 22000 -i ~/.ssh/id_aapmapa aapmapa@194.247.8.74 -L 8787:127.0.0.1:8787'

# monitor nvidia GPU
alias ntop='watch -n 1 nvidia-smi'
