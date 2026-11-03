# ~/.bashrc.d/options.sh
# shellcheck shell=bash

PROMPT_COMMAND+=(
  'history -a'
  'printf "\033]133;A\007"'
  'printf "\033]7;file://%s%s\007" "${HOSTNAME}" "${PWD}"'
)

[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ] && \. /usr/share/git-core/contrib/completion/git-prompt.sh

PS1='\[\e[33m\]\u\[\e[0m\]@\[\e[35m\]\h\[\e[0m\] \[\e[34m\]\W\[\e[0m\]$(__git_ps1 " (%s)") \$ '

HISTCONTROL=erasedups:ignoreboth
HISTSIZE=10000
HISTTIMEFORMAT='%F %T  '

shopt -s autocd
shopt -s checkwinsize
shopt -s globstar
shopt -s histappend
