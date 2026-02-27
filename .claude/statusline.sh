#!/bin/bash
# Claude Code status line - TokyoNight style
# Matches Ghostty theme (TokyoNight Night) and Starship prompt colors

# Read JSON input from stdin
input=$(cat)

# TokyoNight Night colors (256-color approximations)
# Matching palette from Starship: #769ff0, #a3aed2, #394260
BLUE='\033[38;5;111m'     # #769ff0 - primary accent (git branch bg in Starship)
PERIWINKLE='\033[38;5;146m' # #a3aed2 - secondary accent (directory bg in Starship)
GREEN='\033[38;5;114m'    # #9ece6a - TokyoNight green
CYAN='\033[38;5;117m'     # #7dcfff - TokyoNight cyan
PURPLE='\033[38;5;141m'   # #bb9af7 - TokyoNight magenta
ORANGE='\033[38;5;215m'   # #ff9e64 - TokyoNight orange
RESET='\033[0m'

# Extract values from JSON
CONTEXT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d'.' -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
MODEL=$(echo "$input" | jq -r '.model.display_name // "claude"')

# Get git branch if in repo
GIT_INFO=""

if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    REPOSITORY=$(basename -s .git $(git config --get remote.origin.url))
    [ -n "$BRANCH" ] && GIT_INFO=" | ${GREEN} ${REPOSITORY}@${BRANCH}${RESET} "
fi

# Format cost to 2 decimal places, only show if > $0.00
COST_DISPLAY=""
if [ "$(echo "$COST > 0" | bc -l 2>/dev/null)" = "1" ]; then
    COST_FMT=$(printf "%.2f" "$COST")
    COST_DISPLAY=" | ${CYAN}Session cost: \$${COST_FMT}${RESET}"
fi

# Context color based on usage (matches TokyoNight severity scale)
if [ "$CONTEXT" -gt 75 ]; then
    CTX_COLOR="${ORANGE}"
elif [ "$CONTEXT" -gt 50 ]; then
    CTX_COLOR="${PURPLE}"
else
    CTX_COLOR="${PERIWINKLE}"
fi

STATUS="${BLUE}${MODEL}${RESET}${GIT_INFO}| ${CTX_COLOR}Context used: ${CONTEXT}%${RESET}${COST_DISPLAY}"

echo -e "${STATUS}\n"
