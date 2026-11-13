# ~/.bashrc.d/ssh-agent.sh
# shellcheck shell=bash

env="${HOME}/.ssh/agent.env"

[ -f "$env" ] && \. "$env" >/dev/null

# 0=agent running w/ key; 1=agent w/o key; 2=agent not running
state="$(
	ssh-add -l >/dev/null 2>&1
	echo $?
)"

if [ -z "${SSH_AUTH_SOCK:-}" ] || [ "$state" -eq 2 ]; then
	(
		umask 077
		ssh-agent >"$env"
	)
	\. "$env" >/dev/null
fi

unset -v env state
