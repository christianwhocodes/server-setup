#!/bin/bash
set -e
set -u
# https://github.com/pyenv/pyenv

curl https://pyenv.run | bash
echo '# pyenv' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
echo '# pyenv' >> ~/.profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init -)"' >> ~/.profile
source ~/.profile
pyenv install 3.13.3
pyenv global 3.13.3
pip install --upgrade pip
pip install poetry notebook
poetry config virtualenvs.in-project true

echo "✓ Pyenv, python, pip, Poetry and Jupyter Notebook installed"