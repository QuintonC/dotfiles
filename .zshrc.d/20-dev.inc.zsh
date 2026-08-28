#!/bin/zsh

# include the dev environment if available
if [ -f /opt/dev/dev.sh ]; then
  source /opt/dev/dev.sh
  export PATH="$HOME/.dev/userprofile/bin:$PATH"
  export ENABLE_TOOL_SEARCH=true
  alias omp='devx omp'

  # shadowenv sets HOST inside project dirs and unsets it on exit, clobbering zsh's HOST.
  # Ghostty builds its OSC 7 cwd report from $HOST and drops non-local ones, so new tabs/splits stop following the cwd.
  typeset -g __osc7_host="${HOST:-${(%):-%M}}"

  __osc7_report_cwd() {
    printf '\e]7;kitty-shell-cwd://%s%s\a' "$__osc7_host" "$PWD"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd __osc7_report_cwd
fi
