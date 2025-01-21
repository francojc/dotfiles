#!/usr/bin/env bash

# Description: A script to get the 'git status' recursively in for child directories
# of the current directory
# Usage: ./get-git-statuses.sh
#

# Get the list of directories
# Exclude the .git directory and hidden directories
directories=$(find . -type d -not -path '*/\.*' -not -path '*/.git' -print)

# Loop through the directories and get the git status
for dir in $directories
do
    # Check if the directory is a git repository
    if [ -d "$dir/.git" ]; then
        echo "Directory: $dir"
        # Get the git status
        git -C $dir status
        echo "-----------------------------------"
        echo ""
    fi
done

# End of script
