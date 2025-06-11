#!/usr/bin/env bash

# This script changes the remote URL of a Git repository from HTTP to SSH.

# Check if a Git repository exists in the current directory
if [ ! -d .git ]; then
  echo "This is not a Git repository. Please navigate to a Git repository directory."
  exit 1
fi

# Get the current HTTP remote URL
current_url=$(git remote get-url origin)

# Validate that the URL is a GitHub HTTP URL
if [[ $current_url != https://github.com/* ]]; then
  echo "The current remote URL is not an HTTP URL pointing to GitHub. No changes made."
  exit 1
fi

# Extract the owner/repo part of the URL
repo_part=${current_url#https://github.com/}

# Construct the SSH URL
ssh_url="git@github.com:${repo_part%.git}.git"

# Change the remote URL to the SSH version
git remote set-url origin "$ssh_url"

echo "Remote URL changed from HTTP to SSH successfully."
echo "New remote URL: $ssh_url"
