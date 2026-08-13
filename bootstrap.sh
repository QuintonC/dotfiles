#!/bin/bash

# auto-install oh-my-zsh
if [ ! -f "${HOME}/.oh-my-zsh/oh-my-zsh.sh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# auto-install bun
if [ ! -d "${HOME}/.bun" ]; then
  sh -c "$(curl -fsSL https://bun.sh/install | bash)"
fi

# auto-install nvm
if [ ! -d "${HOME}/.nvm" ]; then
  # We install using the script, but explicitly tell nvm to not edit the shell config
  sh -c "$(PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash)"
fi

# .dotfiles to bootstrap
declare -a BOOTSTRAP_FILES=(
  .agents
  .claude
  .config
  .oh-my-zsh
  .omp
  .pi
  .gitconfig.local
  .tmux.conf
  .zshrc.d
)

rsync -avh ${BOOTSTRAP_FILES[@]} "${HOME}/"

if [ -f /etc/zsh/zshrc.default.inc.zsh ]; then
  # assume that this default file will load our .zshrc.d/* files
  rsync -avh /etc/zsh/zshrc.default.inc.zsh "${HOME}/.zshrc"
else
  # if this replaces an existing config, check $HOME/.zshrc.pre-oh-my-zsh
  rsync -avh .zshrc "${HOME}/.zshrc"
fi