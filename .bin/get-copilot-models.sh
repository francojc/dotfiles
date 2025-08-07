#!/usr/bin/env bash

# Fetch available GitHub Copilot models and print their IDs to stdout
# Requires $OPENAI_API_KEY to be set in the environment

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY environment variable is not set." >&2
  exit 1
fi

curl -s https://api.githubcopilot.com/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Copilot-Integration-Id: vscode-chat" | jq -r '.data[].id'
