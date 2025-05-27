#!/bin/bash
set -e

cat <<'EOF' > "/home/$USERNAME/.bash_aliases"
# ======= OS Detection =======

OS_TYPE="$(uname -s)"

case "$OS_TYPE" in
    Linux)
        PYTHON_CMD="python3"
        REPOS="$HOME/repos"
        ;;
    MINGW*|CYGWIN*|MSYS*)
        PYTHON_CMD="python"
        REPOS="/d/Repositories"
        ;;
    *)
        echo "Unsupported operating system: $OS_TYPE" >&2
        return 1
        ;;
esac

# ======= Repositories =======

function repos {
    cd "$REPOS" || echo "Directory $REPOS does not exist"
}

# ======= Python & Virtualenv =======

alias createvenv="$PYTHON_CMD -m venv ./.venv"
alias activatevenv="source .venv/bin/activate"
alias installreq="$PYTHON_CMD -m pip install --upgrade pip && pip install -r requirements.txt"
# ======= Django =======

function d {
    if [ -f "poetry.lock" ]; then
        poetry run $PYTHON_CMD manage.py "$@"
    elif [ -f "Pipfile" ]; then
        pipenv run $PYTHON_CMD manage.py "$@"
    else
        $PYTHON_CMD manage.py "$@"
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

# ======= Misc =======

alias update="sudo apt update && sudo apt -y upgrade && sudo apt autoclean && sudo apt autoremove"
alias editaliases="nano ~/.bash_aliases"
alias refresh="source ~/.bashrc and exec \"$SHELL\""
alias showaliases="cat ~/.bash_aliases"
alias la="ls -a"
alias code_server_update="curl -fsSL https://code-server.dev/install.sh | sh"

function remove_recursively {
    local folderPath=$1
    local pattern=$2
    local targetType=$3
    local force=$4

    if [ -z "$folderPath" ] || [ -z "$pattern" ]; then
        echo "Usage: remove_recursively <folderPath> <fileName|extension> [-f] [-d]"
        echo "       -d : Remove directories instead of files"
        echo "       -f : Force deletion (no confirmation)"
        return 1
    fi

    folderPath=$(realpath "$folderPath")

    if [ "$folderPath" = "/" ] || [ "$folderPath" = "$HOME" ]; then
        echo "⚠️  Error: Refusing to delete files in '$folderPath' (to prevent system damage)."
        return 1
    fi

    if [[ "$pattern" == .* ]]; then
        pattern="*$pattern"
    fi

    echo "🛑 You are about to delete items in: $folderPath"
    if [ "$targetType" = "-d" ]; then
        echo "📁 Target: All directories named '$pattern'"
    elif [[ "$pattern" == *.* ]]; then
        echo "📄 Target: All files with extension '$pattern'"
    else
        echo "📄 Target: All files named '$pattern'"
    fi

    if [ "$force" != "-f" ]; then
        read -p "❓ Are you sure? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "❌ Deletion cancelled."
            return 1
        fi
    fi

    if [ "$targetType" = "-d" ]; then
        find "$folderPath" -type d -name "$pattern" -exec rm -r {} +
    else
        find "$folderPath" -type f -name "$pattern" -exec rm {} +
    fi

    echo "✅ Deletion complete."
}
EOF

chown "$USERNAME:$USERNAME" "/home/$USERNAME/.bash_aliases"
chmod 644 "/home/$USERNAME/.bash_aliases"

echo "✓ .bash_aliases created for $USERNAME"
