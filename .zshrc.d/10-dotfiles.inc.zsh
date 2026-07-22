#!/bin/zsh

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Update frequency
# just remind me to update when it's time
zstyle ':omz:update' mode reminder

# Plugins
plugins=(command-not-found git rails)

# initialize omz
source "${ZSH}/oh-my-zsh.sh"