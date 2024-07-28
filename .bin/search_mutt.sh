#!/bin/bash

# Check if account name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <account_name>"
    exit 1
fi

# Use the provided account name to set the mail directory
MAIL_DIR="$HOME/.local/share/mail/$1"

# File to store results
RESULTS_FILE="$HOME/.cache/mutt_results"

# Clear previous results
> "$RESULTS_FILE"

# Use fzf to browse and search, then use ripgrep to search within the selected file
selected=$(find "$MAIL_DIR" -type f | \
           fzf --preview "rg --pretty --context 5 {} || cat {}" \
               --bind "ctrl-r:reload(rg --files '$MAIL_DIR')" \
               --header 'Press CTRL-R to reload' \
               --preview-window=right:50%)

# If a file was selected, write its path to the results file
if [ -n "$selected" ]; then
    echo "$selected" > "$RESULTS_FILE"
fi
