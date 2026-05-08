#!/bin/zsh

for d in */ ; do
  stow -D "$d"
done
