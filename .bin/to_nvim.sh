#!/usr/bin/env bash

# This script takes a list of files and opens them in neovim in a new WezTerm terminal.

for f in "$@"
do
    open -na "WezTerm" --args -e nvim "$f"
done

