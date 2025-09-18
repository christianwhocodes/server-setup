#!/bin/bash
set -e

rm -f "/home/$USER/.bash_aliases"
touch "/home/$USER/.bash_aliases"

cat << EOF > "/home/$USER/.bash_aliases"
# ======= Misc =======
alias update="sudo apt update && sudo apt -y upgrade && sudo apt autoclean && sudo apt autoremove"
alias editaliases="nano ~/.bash_aliases"
alias refresh='source ~/.bashrc && exec "$SHELL"'
alias showaliases="cat ~/.bash_aliases"
alias la="ls -a"
function repos { cd "$HOME/repos" || echo "Directory $HOME/repos does not exist" }

# ======= Python & Virtualenv =======
alias createvenv="python3 -m venv ./.venv"
alias activatevenv="source .venv/bin/activate"

# ======= Django =======
function d {
    if [ -f "poetry.lock" ]; then
        poetry run python3 manage.py "$@"
    elif [ -f "Pipfile" ]; then
        pipenv run python3 manage.py "$@"
    else
        python3 manage.py "$@"
    fi
}

# Run Django development server on localhost (127.0.0.1), default port 8000
function drun() {
    local port="${1:-8000}"
    d runserver "127.0.0.1:${port}"
}

# Run Django development server on 0.0.0.0 (accessible from network), default port 8000
function drun0() {
    local port="${1:-8000}"
    d runserver "0.0.0.0:${port}"
}

# ======= PostgreSQL =======
alias postgres="sudo service postgresql"

# ======= Nginx =======
alias nginxerrorlog="sudo nano /var/log/nginx/error.log"
alias sitesavailable="cd /etc/nginx/sites-available/"
alias sitesenabled="cd /etc/nginx/sites-enabled/"
alias nginx="sudo service nginx"
alias tnginx="sudo nginx -t"
function nginxedit { sudo nano /etc/nginx/sites-available/$1; }
function nginxlink { sudo ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/; }
function nginxunlink { sudo unlink /etc/nginx/sites-enabled/$1; }

# ======= PHP =======
alias php="sudo service php8.2-fpm"

# ======= Code Server =======
alias code_server_update="curl -fsSL https://code-server.dev/install.sh | sh"
EOF

chown "$USER:$USER" "/home/$USER/.bash_aliases"
chmod 644 "/home/$USER/.bash_aliases"
