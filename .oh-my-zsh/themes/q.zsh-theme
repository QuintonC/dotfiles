# start with the base theme
source $ZSH/themes/robbyrussell.zsh-theme

zstyle ':omz:update' mode reminder

# better git prompt
# requires git-prompt plugin
# first override the default theme vars
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"
# space instead of pipe
ZSH_THEME_GIT_PROMPT_SEPARATOR=" "

PROMPT_Q_PREFIX='➜'
if [ ! -z "${SPIN}" ]; then
  PROMPT_Q_PREFIX="꩜ ${PROMPT_Q_PREFIX}"
fi

# original prompt from robbyrussell
# PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT="%(?:%{$fg_bold[green]%}${PROMPT_Q_PREFIX}:%{$fg_bold[red]%}${PROMPT_Q_PREFIX})"
PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%}'

if [ -z "${__GIT_PROMPT_DIR}" ]; then
  PROMPT+=' '
else
  PROMPT+=' $(git_super_status)'
fi