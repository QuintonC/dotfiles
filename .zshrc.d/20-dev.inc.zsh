#!/bin/zsh

# include the dev environment if available
if [ -f /opt/dev/dev.sh ]; then
  source /opt/dev/dev.sh
  export PATH="$HOME/.dev/userprofile/bin:$PATH"
  export DEVX_CLAUDE_FEATURE_CONTEXT_WINDOW_250K=false
  export ENABLE_TOOL_SEARCH=true
fi
