#!/usr/bin/env bash

# Setup script for Google Directory to Emailbook integration
# This script will install required dependencies and set up a cron job

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Google Directory to Emailbook integration...${NC}"

# Check if the required packages are installed, but do not attempt to install them. Only provide a message and exit
echo -e "\n${YELLOW}Checking for required Python packages...${NC}"
if ! python3 -c "import googleapiclient, google_auth_httplib2, google_auth_oauthlib" 2>/dev/null; then
    echo -e "${RED}Error: Required Python packages not found. Please enter the nix development shell first with:${NC}"
    echo -e "${RED}nix develop .bin -c bash${NC}"
    echo -e "${RED}Then re-run this setup script from within the nix shell.${NC}"
    exit 1
fi

# Create config directory
mkdir -p ~/.config
mkdir -p ~/.local/share/emailbook

# Check for the converter script
SCRIPT_PATH="$HOME/.bin/google-directory-to-emailbook.py"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "\n${YELLOW}Installing the converter script...${NC}"
    mkdir -p ~/.local/bin

    # Copy the script content to the destination
    cat > "$SCRIPT_PATH" << 'EOF'
#!/usr/bin/env python3
"""
Google Directory API to Emailbook Converter

This script fetches contacts from a Google Workspace Directory and converts them
to emailbook format (https://sr.ht/~maxgyver83/emailbook/).

Requirements:
- Google API Client: pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
- University Google Workspace account with proper API access

Set up instructions:
1. Enable the Admin SDK API in the Google Cloud Console
2. Create OAuth credentials (Desktop application) and download the JSON file
3. Place the credentials file at ~/.config/google-directory-credentials.json
4. Run this script once to authenticate and save the token
5. Set up a cron job to run it regularly
"""

import os
import json
import pickle
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# Configuration
SCOPES = ['https://www.googleapis.com/auth/admin.directory.user.readonly']
TOKEN_FILE = os.path.expanduser('~/.config/google-directory-token.pickle')
CREDENTIALS_FILE = os.path.expanduser('~/.config/google-directory-credentials.json')
EMAILBOOK_DIR = os.path.expanduser('~/.local/share/emailbook')
EMAILBOOK_FILE = os.path.join(EMAILBOOK_DIR, 'emails')

# Your university's domain
DOMAIN = 'wfu.edu'  # Replace with your actual university domain

def get_google_directory_service():
    """
    Authenticate with Google and return a service object for the Directory API.
    Handles token refresh and initial authentication flow.
    """
    creds = None

    # Load the existing token if it exists
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'rb') as token:
            creds = pickle.load(token)

    # If no valid credentials available, authenticate
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(CREDENTIALS_FILE):
                raise FileNotFoundError(
                    f"Credentials file not found at {CREDENTIALS_FILE}. "
                    "Please download OAuth credentials from Google Cloud Console."
                )

            flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_FILE, SCOPES)
            creds = flow.run_local_server(port=0)

        # Save the credentials for the next run
        with open(TOKEN_FILE, 'wb') as token:
            pickle.dump(creds, token)

    # Build and return the service
    service = build('admin', 'directory_v1', credentials=creds)
    return service

def fetch_directory_contacts(service, domain=DOMAIN, max_results=500):
    """
    Fetch contacts from the Google Directory API.

    Args:
        service: Google API service object
        domain: Domain to fetch users from
        max_results: Maximum number of results to return per page

    Returns:
        List of user dictionaries with name and email information
    """
    contacts = []
    page_token = None

    # Keep fetching pages of results until there are no more
    while True:
        results = service.users().list(
            domain=domain,
            maxResults=max_results,
            pageToken=page_token,
            orderBy='email',
            fields='users(name,primaryEmail,emails),nextPageToken'
        ).execute()

        users = results.get('users', [])
        contacts.extend(users)

        page_token = results.get('nextPageToken')
        if not page_token:
            break

    return contacts

def write_emailbook_format(contacts, output_file):
    """
    Write contacts to emailbook format.

    The emailbook format is:
    name1 <email1>
    name2 <email2>
    ...

    Args:
        contacts: List of contact dictionaries
        output_file: Path to output file
    """
    # Make sure the directory exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        for contact in contacts:
            name = contact.get('name', {})
            full_name = f"{name.get('givenName', '')} {name.get('familyName', '')}".strip()

            # Use email address as name if no name is provided
            if not full_name and 'primaryEmail' in contact:
                full_name = contact['primaryEmail'].split('@')[0]

            # Write the primary email
            if 'primaryEmail' in contact:
                f.write(f"{full_name} <{contact['primaryEmail']}>\n")

            # Write any additional email addresses
            if 'emails' in contact:
                for email_obj in contact['emails']:
                    email = email_obj.get('address', '')
                    # Skip the primary email as we already wrote it
                    if email and email != contact.get('primaryEmail', ''):
                        f.write(f"{full_name} <{email}>\n")

def main():
    """Main function to fetch and convert contacts."""
    print(f"Connecting to Google Directory API for domain {DOMAIN}...")

    try:
        # Authenticate and get the directory service
        service = get_google_directory_service()

        # Fetch contacts from the directory
        print("Fetching contacts from directory...")
        contacts = fetch_directory_contacts(service)
        print(f"Retrieved {len(contacts)} contacts from the directory.")

        # Convert and save in emailbook format
        print(f"Writing contacts to emailbook format at {EMAILBOOK_FILE}...")
        write_emailbook_format(contacts, EMAILBOOK_FILE)

        print("Done! Your contacts have been updated.")

    except Exception as e:
        print(f"Error: {str(e)}")
        return 1

    return 0

if __name__ == "__main__":
    exit(main())
EOF

    # Make the script executable
    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}Converter script installed at $SCRIPT_PATH${NC}"
fi

# Prompt for domain update
echo -e "\n${YELLOW}What is your university's domain? (e.g., wfu.edu)${NC}"
read DOMAIN

# Update the domain in the script
if [ -n "$DOMAIN" ]; then
    sed -i "s/DOMAIN = 'wfu.edu'/DOMAIN = '$DOMAIN'/" "$SCRIPT_PATH"
    echo -e "${GREEN}Domain updated to $DOMAIN${NC}"
fi

# Set up cron job
echo -e "\n${YELLOW}How often would you like to update contacts?${NC}"
echo "1) Daily"
echo "2) Weekly"
echo "3) Monthly"
echo "4) No cron job (manual updates only)"
read -p "Enter your choice (1-4): " CRON_CHOICE

CRON_CMD="$SCRIPT_PATH > ~/.local/share/emailbook/update.log 2>&1"

case $CRON_CHOICE in
    1)
        CRON_SCHEDULE="0 5 * * *"  # 5 AM daily
        CRON_DESC="daily at 5 AM"
        ;;
    2)
        CRON_SCHEDULE="0 5 * * 0"  # 5 AM on Sundays
        CRON_DESC="weekly on Sundays at 5 AM"
        ;;
    3)
        CRON_SCHEDULE="0 5 1 * *"  # 5 AM on the 1st of each month
        CRON_DESC="monthly on the 1st at 5 AM"
        ;;
    4)
        CRON_SCHEDULE=""
        echo -e "${GREEN}No cron job will be set up. You can run the script manually when needed.${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. No cron job will be set up.${NC}"
        CRON_SCHEDULE=""
        ;;
esac

if [ -n "$CRON_SCHEDULE" ]; then
    # Check if crontab exists
    crontab -l > /tmp/current_crontab 2>/dev/null || echo "" > /tmp/current_crontab

    # Check if the cron job already exists
    if grep -q "$SCRIPT_PATH" /tmp/current_crontab; then
        # Update existing cron job
        sed -i "\|$SCRIPT_PATH|c\\$CRON_SCHEDULE $CRON_CMD" /tmp/current_crontab
    else
        # Add new cron job
        echo "$CRON_SCHEDULE $CRON_CMD" >> /tmp/current_crontab
    fi

    # Install new crontab
    crontab /tmp/current_crontab
    rm /tmp/current_crontab

    echo -e "${GREEN}Cron job set up to run $CRON_DESC${NC}"
fi

# Instructions for OAuth credentials
echo -e "\n${YELLOW}==== NEXT STEPS =====${NC}"
echo -e "1. Go to the Google Cloud Console (https://console.cloud.google.com/)"
echo -e "2. Create a new project for your university contacts"
echo -e "3. Enable the Admin SDK API"
echo -e "4. Create OAuth credentials (Desktop application type)"
echo -e "5. Download the JSON credentials file"
echo -e "6. Save the file as: ${GREEN}~/.config/google-directory-credentials.json${NC}"
echo -e "7. Run the script once to authenticate: ${GREEN}$SCRIPT_PATH${NC}"
echo -e "   (This will open a browser window for OAuth authentication)"
echo -e "\n${GREEN}After completion, your contacts will be available at:${NC}"
echo -e "${GREEN}~/.local/share/emailbook/emails${NC}"
echo -e "\n${YELLOW}To configure emailbook with your email client, follow the instructions at:${NC}"
echo -e "${GREEN}https://sr.ht/~maxgyver83/emailbook/${NC}"

echo -e "\n${GREEN}Setup complete!${NC}"
