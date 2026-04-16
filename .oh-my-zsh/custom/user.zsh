#!/bin/zsh

# homebrew integration
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "/usr/local/bin/brew" ] && eval "$(/usr/local/bin/brew shellenv)"
# Prevent binaries such as git from shadowing the versions provided by tec (if tec is present)
[ -f "~/.local/state/tec/profiles/base/current/global/init" ] && eval "$(~/.local/state/tec/profiles/base/current/global/init --zsh)"
export PATH=$PATH:/opt/homebrew/bin

# local bin
[ -d "${HOME}/bin" ] && export PATH=${HOME}/bin:$PATH

# common shell configuration
[ -f "${HOME}/.commonrc" ] && source "${HOME}/.commonrc"

# bun configuration
[ ! -d "$HOME/.bun" ] && mkdir -p "$HOME/.bun"
[ -s "$HOME/.bun/_bun" ] && \. "$HOME/.bun/_bun"
[ -z "$BUN_INSTALL" ] && export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm configuration
if [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi

# nvm
[ ! -d "$HOME/.nvm" ] && mkdir -p "$HOME/.nvm"
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# rbenv
# eval "$(rbenv init -)"

# starship
eval "$(starship init zsh)"

# initialize git config
touch "${HOME}/.gitconfig"
if [ -f "${HOME}/.gitconfig.local" ]; then
  grep -qF ".gitconfig.local" "${HOME}/.gitconfig" || echo -e "[include]\n  path = ${HOME}/.gitconfig.local" >> "${HOME}/.gitconfig"
fi