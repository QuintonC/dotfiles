#!/bin/zsh

# include the dev environment if available
if [ -f /opt/dev/dev.sh ]; then
  source /opt/dev/dev.sh
  export PATH="$HOME/.dev/userprofile/bin:$PATH"
fi
