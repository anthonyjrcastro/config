# ~/.bashrc
# shellcheck shell=bash

[[ -f '/etc/bashrc' ]] && source '/etc/bashrc'

# Remove duplicates: https://unix.stackexchange.com/a/124517
PATH=$(printf %s "$PATH" | awk -vRS=: '!a[$0]++' | paste -s -d:)

# Auto-launch ssh-agent: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows

env="${HOME}/.ssh/agent.env"

[[ -f $env ]] && source "$env" >/dev/null

# 0=agent running w/ key; 1=agent w/o key; 2=agent not running
state=$(
  ssh-add -l &>/dev/null
  echo $?
)

if [[ -z ${SSH_AUTH_SOCK:-} ]] || ((state == 2)); then
  (
    umask 077
    ssh-agent >|"$env"
  )
  source "$env" >/dev/null
fi

unset env state

PROMPT_COMMAND+=(
  'history -a'
  'printf "\033]133;A\007"'
  'printf "\033]7;file://%s%s\007" "${HOSTNAME}" "${PWD}"'
)

PS1='\[\e[33m\]\u\[\e[0m\]@\[\e[35m\]\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\] \$ '

HISTCONTROL='erasedups:ignoreboth'
HISTSIZE=10000
HISTTIMEFORMAT='%F %T  '

shopt -s autocd
shopt -s checkwinsize
shopt -s globstar
shopt -s histappend

# https://unix.stackexchange.com/a/452869
set -o noclobber

bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# `C-s`: https://stackoverflow.com/a/25391867
[[ $- == *i* ]] && stty -ixon

[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"

[[ -s "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

alias ls='ls --color=auto' 2>/dev/null
alias l.='ls -d .* --color=auto' 2>/dev/null
alias la='ls -A --color=auto' 2>/dev/null
alias ll='ls -lh --color=auto' 2>/dev/null

alias ...='../..' 2>/dev/null
alias ....='../../..' 2>/dev/null
alias .....='../../../..' 2>/dev/null
alias ......='../../../../..' 2>/dev/null

alias grep='grep --color=auto' 2>/dev/null
alias egrep='grep -E --color=auto' 2>/dev/null
alias fgrep='grep -F --color=auto' 2>/dev/null

alias xzgrep='xzgrep --color=auto' 2>/dev/null
alias xzegrep='xzegrep --color=auto' 2>/dev/null
alias xzfgrep='xzfgrep --color=auto' 2>/dev/null

alias zgrep='zgrep --color=auto' 2>/dev/null
alias zegrep='zegrep --color=auto' 2>/dev/null
alias zfgrep='zfgrep --color=auto' 2>/dev/null
