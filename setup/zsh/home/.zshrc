#!/bin/zsh

# Add ompp to path - http://www.ompp-tool.com/
export PATH="${PATH}:/opt/ompp/bin"

# Enable completion
autoload -U compinit
compinit

# Set the completion style
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# Enable correction
setopt correctall

# Update the commmand prompt
autoload -U promptinit
promptinit
prompt gentoo

# Enable extended globbing
setopt extendedglob

# Enable innteractive comments
setopt interactivecomments

# Enable command history
export HISTSIZE=4000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups

# Alias ls to color
alias ls='ls -h --color=auto'
alias tree='tree -C'
alias sshno='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# Enable date-time functions
zmodload zsh/datetime

# Enable math functions
zmodload zsh/mathfunc
