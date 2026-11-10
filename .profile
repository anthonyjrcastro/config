# ~/.profile
# shellcheck shell=sh

pathadd() {
  [ -d "$1" ] || return

  case ":${PATH}:" in
    *:"$1":*) ;;
    *)
      PATH="$1${PATH:+:$PATH}"
      ;;
  esac
}

pathadd /opt/jdt-language-server/bin

unset -f pathadd

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export MANPAGER='nvim +Man!'
elif command -v vi >/dev/null 2>&1; then
  export EDITOR=vi
fi

export NVM_DIR="${HOME}/.nvm"

export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1

export UV_NO_MODIFY_PATH=1
