# ~/.bash_profile
# shellcheck shell=bash

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  \. ~/.bashrc
fi

# User specific environment and startup programs
if [ -f ~/.profile ]; then
  \. ~/.profile
fi
