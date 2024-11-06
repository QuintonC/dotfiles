#!/bin/zsh

# for https://github.com/agkozak/zsh-z
# make sure the database file exists
touch "${HOME}/.z"

plugins=(
  command-not-found
  git
  git-prompt
  rails
)