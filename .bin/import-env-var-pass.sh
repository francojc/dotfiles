#!/usr/bin/env bash

# Description: This script takes an environment variable file .env as input and exports all the variables in the file to the `pass` password manager store.
# The .env file passwords and keys are in the format:
# KEY=VALUE
# The script will prompt for the password to be used to encrypt the values in the password store.
#
# Usage: ./import-env-var-pass.sh <.env file path>
#
# Example: ./import-env-var-pass.sh ~/.variables.env

# Check if the pass command is installed,
# if not, stop and prompt the user to install it.

if ! command -v pass &> /dev/null; then
    echo "pass command could not be found. Please install pass password manager."
    exit 1
fi

# Check if the .env file is provided as input.
# If not, stop and prompt the user to provide the file.

if [ -z "$1" ]; then
    echo "Please provide the .env file path as input."
    exit 1
fi

# Check if the .env file exists.
# If not, stop and prompt the user to provide the correct file.

if [ ! -f "$1" ]; then
    echo "The file $1 does not exist. Please provide the correct file path."
    exit 1
fi

# Check if pass store is already initialized
if [ -d "$HOME/.password-store" ]; then
    # Verify GPG key is properly set up
    GPG_ID=$(cat "$HOME/.password-store/.gpg-id" 2>/dev/null)
    if [ -z "$GPG_ID" ]; then
        echo "No GPG ID found in password store. Please reinitialize pass with: pass init <gpg-id>"
        exit 1
    fi

    # Verify the GPG key is available and valid
    if ! gpg --list-keys "$GPG_ID" &>/dev/null; then
        echo "GPG key $GPG_ID not found or not valid. Please check your GPG key setup."
        exit 1
    fi
else
    # Check if GPG key exists and prompt user to select one if multiple exist
    GPG_KEYS=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2)

    if [ -z "$GPG_KEYS" ]; then
        echo "No GPG keys found. Please create a GPG key first using: gpg --gen-key"
        exit 1
    fi

    # If multiple keys exist, let user select one
    if [ $(echo "$GPG_KEYS" | wc -l) -gt 1 ]; then
        echo "Multiple GPG keys found. Please select one:"
        select GPG_KEY in $GPG_KEYS; do
            if [ -n "$GPG_KEY" ]; then
                break
            fi
        done
    else
        GPG_KEY=$GPG_KEYS
    fi

    # Initialize pass with the GPG key
    pass init "$GPG_KEY"
fi

# Read the .env file and store each variable in the pass password store
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ! $line =~ ^# && ! -z $line ]]; then
        KEY=$(echo $line | sed 's/^export //' | cut -d '=' -f 1)
        VALUE=$(echo $line | sed 's/^export //' | cut -d '=' -f 2-)

        if pass show "$KEY" &>/dev/null; then
            echo "Updating existing pass entry for $KEY"
        else
            echo "Creating new pass entry for $KEY"
        fi
      printf '%s\n' "$VALUE" | pass insert -f --multiline "$KEY"
    fi
done < "$1"

echo "All variables have been imported into the pass password store."

