#!/usr/bin/env bash

# Export all pass passwords to a file
# in the format of shell variables 'export VAR_NAME=VALUE'
# Usage: export_pass.sh
# Result: ~/.variables.env file with all pass passwords exported
# as shell variables
# Requires pass and gpg

# Set the output file path
OUTPUT_FILE="${HOME}/.variables.env"

# Create or truncate the output file
> "$OUTPUT_FILE"

# Function to safely escape variable names and values
escape_var_name() {
    # Replace non-alphanumeric characters with underscores
    echo "$1" | sed -E 's/[^a-zA-Z0-9_]/_/g'
}

escape_value() {
    # Escape special characters for shell
    printf '%q' "$1"
}

# Find all pass entries
pass_entries=$(find "${PASSWORD_STORE_DIR:-$HOME/.password-store}" -name "*.gpg" | sed 's|.*/\.password-store/||; s|\.gpg$||')

# Export each pass entry
while IFS= read -r entry; do
    # Get the password
    password=$(pass "$entry")

    # Extract the last part of the path and convert to uppercase
    var_name=$(escape_var_name "$(basename "$entry" | tr '[:lower:]' '[:upper:]')")

    # Escape the password value
    escaped_password=$(escape_value "$password")

    # Write to the output file
    echo "export ${var_name}=${escaped_password}" >> "$OUTPUT_FILE"
done <<< "$pass_entries"

# Set appropriate permissions
chmod 600 "$OUTPUT_FILE"

echo "Pass passwords exported to $OUTPUT_FILE"
