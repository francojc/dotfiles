#!/bin/bash

# This script takes a list of files and opens them in neovim in a new Alacritty terminal.

for f in "$@"
do
    open -na "Alacritty" --args -e nvim "$f"
done

