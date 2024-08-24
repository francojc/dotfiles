#!/usr/bin/env bash

# This script takes a list of files and opens them in neovim in a new Kitty terminal.

for f in "$@"
do
    open -na "Kitty" --args -e nvim "$f"
done

