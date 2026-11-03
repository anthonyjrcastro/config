# ~/.bashrc.d/packages.sh
# shellcheck shell=bash

command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"

[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"

[ -s "${HOME}/.cargo/env" ] && \. "${HOME}/.cargo/env"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
