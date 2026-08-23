# ~/.bash_profile
# shellcheck shell=bash

path_add() { # https://superuser.com/a/39995
  if [[ -d $1 && ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}
path_add "${HOME}/bin"
path_add "${HOME}/.local/bin"
path_add '/opt/jdt-language-server/bin'

unset path_add

export PATH

if command -v nvim &>/dev/null; then
  export EDITOR='nvim'
  export MANPAGER='nvim +Man!'
elif command -v vi &>/dev/null; then
  export EDITOR='vi'
fi

export NVM_DIR="${HOME}/.nvm"

export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1

[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
