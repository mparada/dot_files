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
alias cookiecutter='cookiecutter https://github.com/drivendata/cookiecutter-data-science'
