#!/bin/bash
set -e

# Color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Backup existing .bash_aliases if it exists
if [ -f "/home/$USER/.bash_aliases" ]; then
    cp "/home/$USER/.bash_aliases" "/home/$USER/.bash_aliases.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up existing .bash_aliases"
fi

# Create new .bash_aliases file
cat << 'EOF' > "/home/$USER/.bash_aliases"
# ======= Misc =======
alias update="sudo apt update && sudo apt -y upgrade && sudo apt autoclean && sudo apt autoremove"
alias editaliases="nano ~/.bash_aliases"
alias refresh='source ~/.bashrc && exec "$SHELL"'
alias showaliases="cat ~/.bash_aliases"
alias la="ls -a"
alias serve="npx serve --no-clipboard"
function repos { cd "$HOME/repos" || echo "Directory $HOME/repos does not exist"; }

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
function nginxedit { 
    if [ -z "$1" ]; then
        echo "Usage: nginxedit <site-name>"
        return 1
    fi
    sudo nano "/etc/nginx/sites-available/$1"
}
function nginxlink { 
    if [ -z "$1" ]; then
        echo "Usage: nginxlink <site-name>"
        return 1
    fi
    sudo ln -s "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/"
}
function nginxunlink { 
    if [ -z "$1" ]; then
        echo "Usage: nginxunlink <site-name>"
        return 1
    fi
    sudo unlink "/etc/nginx/sites-enabled/$1"
}

# ======= PHP =======
alias php="sudo service php8.2-fpm"

# ======= Code Server =======
alias code_server_update="curl -fsSL https://code-server.dev/install.sh | sh"

# ======= File Management =======
# Remove files/folders recursively with confirmation
# Usage examples:
#   remove_recursively ./src .pyc       # Remove all .pyc files in src directory
#   remove_recursively . node_modules -d # Remove all node_modules directories
#   remove_recursively . .git -d -f     # Force remove all .git directories
function remove_recursively {
    local folderPath="$1"
    local pattern="$2"
    local targetType="file"
    local force="false"
    
    # Parse additional arguments
    shift 2
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d)
                targetType="directory"
                shift
                ;;
            -f)
                force="true"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done

    if [ -z "$folderPath" ] || [ -z "$pattern" ]; then
        echo "Usage: remove_recursively <folderPath> <fileName|extension> [-f] [-d]"
        echo "       -d : Remove directories instead of files"
        echo "       -f : Force deletion (no confirmation)"
        return 1
    fi

    # Safety check for critical directories
    if [ "$folderPath" = "/" ] || [ "$folderPath" = "/home/$USER" ]; then
        echo "⚠️  Error: Refusing to delete files in '$folderPath' (to prevent system damage)."
        return 1
    fi

    # Adjust pattern for hidden files/directories
    if [[ "$pattern" == .* ]]; then
        pattern="*$pattern"
    fi

    echo "🛑 You are about to delete items in: $folderPath"
    if [ "$targetType" = "directory" ]; then
        echo "📁 Target: All directories named '$pattern'"
    elif [[ "$pattern" == *.* ]]; then
        echo "📄 Target: All files with extension '$pattern'"
    else
        echo "📄 Target: All files named '$pattern'"
    fi

    if [ "$force" != "true" ]; then
        read -p "❓ Are you sure? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "❌ Deletion cancelled."
            return 1
        fi
    fi

    if [ "$targetType" = "directory" ]; then
        find "$folderPath" -type d -name "$pattern" -exec rm -rf {} +
    else
        find "$folderPath" -type f -name "$pattern" -exec rm -f {} +
    fi

    echo "✅ Deletion complete."
}
EOF

# Set proper ownership and permissions
chown "$USER:$USER" "/home/$USER/.bash_aliases"
chmod 644 "/home/$USER/.bash_aliases"

# Verify the file syntax
if bash -n "/home/$USER/.bash_aliases" 2>/dev/null; then
    echo -e "${GREEN}✅ Syntax check passed!${NC}"
else
    echo -e "${RED}❌ Syntax check failed. Please review the file.${NC}"
fi