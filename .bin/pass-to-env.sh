#!/usr/bin/env bash

set -euo pipefail

ENV_FILE="$HOME/.variables.env"

extract_passwords() {
  local temp_file
  temp_file=$(mktemp)
  
  {
    echo "# Environment variables generated from pass"
    echo "# Generated on: $(date)"
    echo ""
    
    # Find all .gpg files in the password store
    local pass_dir="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    
    while IFS= read -r gpg_file; do
      # Remove the password store directory prefix and .gpg suffix
      local entry_path="${gpg_file#$pass_dir/}"
      entry_path="${entry_path%.gpg}"
      
      # Skip private-key.asc and other non-password files
      [[ "$entry_path" == "private-key.asc" ]] && continue
      [[ "$entry_path" =~ \.asc$ ]] && continue
      
      # Get the password using pass show
      local password
      password=$(pass show "$entry_path" 2>/dev/null | head -n1)
      
      if [[ -n "$password" ]]; then
        # Extract just the key name (last part of the path)
        local key_name
        key_name=$(basename "$entry_path")
        echo "export $key_name=\"$password\""
      fi
    done < <(find "$pass_dir" -name "*.gpg" -type f | sort)
  } > "$temp_file"
  
  mv "$temp_file" "$ENV_FILE"
}

main() {
  if ! command -v pass &> /dev/null; then
    echo "Error: 'pass' command not found. Please install pass first."
    exit 1
  fi
  
  echo "Extracting passwords from pass store..."
  extract_passwords
  
  chmod 600 "$ENV_FILE"
  echo "Successfully wrote environment variables to $ENV_FILE"
  echo "Total variables: $(grep -c '^export' "$ENV_FILE")"
}

main "$@"