#!/usr/bin/env bash

# pass-keys: GPG key backup utility for pass password manager
#
# This script helps backup and restore GPG keys used by the pass password manager.
# It uses age encryption for secure storage and transfer of keys.
#
# Requirements:
#   - pass (password manager)
#   - gpg (GNU Privacy Guard)
#   - age (file encryption tool)
#
# Usage:
#   ./pass-keys.sh -e [directory]  Export and encrypt GPG keys
#   ./pass-keys.sh -i [directory]  Decrypt and import GPG keys
#
# Examples:
#   ./pass-keys.sh -e              Export to default location (~/.gpg_backup)
#   ./pass-keys.sh -e ~/backups    Export to specified directory
#   ./pass-keys.sh -i              Import from default location
#
# The script will create an encrypted archive (backup.age) containing:
#   - public.gpg: Public GPG key
#   - private.gpg: Private GPG key (sensitive!)
#   - trustdb.txt: GPG trust database

BACKUP_DIR="$HOME/.gpg_backup"
ARCHIVE_NAME="backup.age"

usage() {
    echo "Usage: $0 [-e|-i] [directory]"
    echo "  -e: Export and encrypt GPG keys"
    echo "  -i: Decrypt and import GPG keys"
    echo "  directory: Optional backup directory (default: $BACKUP_DIR)"
    exit 1
}

check_dependencies() {
    for cmd in gpg age tar; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: $cmd is required but not installed."
            echo "Install with: brew install $cmd"
            exit 1
        fi
    done
}

export_keys() {
    local dir="${1:-$BACKUP_DIR}"
    local temp_dir=$(mktemp -d)

    # Get the key ID used by pass
    PASS_KEY=$(cat ~/.password-store/.gpg-id)
    if [ -z "$PASS_KEY" ]; then
        echo "No pass GPG ID found. Is pass initialized?"
        rm -rf "$temp_dir"
        exit 1
    fi

    echo "Exporting GPG keys..."
    gpg --export --armor "$PASS_KEY" > "$temp_dir/public.gpg"
    gpg --export-secret-keys --armor "$PASS_KEY" > "$temp_dir/private.gpg"
    gpg --export-ownertrust > "$temp_dir/trustdb.txt"

    # Create directory if it doesn't exist
    mkdir -p "$dir"

    echo "Encrypting backup..."
    tar czf - -C "$temp_dir" . | age -p > "$dir/$ARCHIVE_NAME"

    # Clean up
    rm -rf "$temp_dir"

    echo "Encrypted backup created at: $dir/$ARCHIVE_NAME"
    echo "Please store the encryption password safely!"
}

import_keys() {
    local dir="${1:-$BACKUP_DIR}"
    local temp_dir=$(mktemp -d)

    if [ ! -f "$dir/$ARCHIVE_NAME" ]; then
        echo "Backup not found at: $dir/$ARCHIVE_NAME"
        rm -rf "$temp_dir"
        exit 1
    fi

    echo "Decrypting backup..."
    age -d "$dir/$ARCHIVE_NAME" | tar xzf - -C "$temp_dir"

    echo "Importing GPG keys..."
    gpg --import "$temp_dir/public.gpg"
    gpg --import "$temp_dir/private.gpg"

    if [ -f "$temp_dir/trustdb.txt" ]; then
        gpg --import-ownertrust "$temp_dir/trustdb.txt"
    fi

    # Clean up
    rm -rf "$temp_dir"

    echo "Keys imported successfully"
}

# Check dependencies first
check_dependencies

# Parse arguments
while getopts "ei" opt; do
    case $opt in
        e)
            export_keys "$2"
            exit 0
            ;;
        i)
            import_keys "$2"
            exit 0
            ;;
        *)
            usage
            ;;
    esac
done

# If no options provided
usage
