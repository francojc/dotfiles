#!/usr/bin/env python3

"""
NOTE:
    This script must be run from the ~/.bin directory!

Personal Google Contacts to Emailbook Converter

This script fetches contacts data from your personal Google account
and converts it to the emailbook format.

This approach doesn't require admin privileges.

Requirements:
- google-api-python-client
- google-auth
- google-auth-oauthlib

Setup:
1. Install dependencies via .bin/flake.nix
2. Create OAuth credentials in Google Cloud Console
3. Download the OAuth client credentials JSON file
4. Run the script and authenticate in your browser
"""

import os
import pickle
import argparse
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# Configuration

CONFIG = {
    "credentials_file": "~/.config/aerc/google-aerc-credentials.json",  # OAuth client credentials
    "token_file": "~/.config/aerc/token.pickle",  # To store your access token
    "output_file": "~/.emailbook.txt",  # Where to save the emailbook file
    "scopes": ["https://www.googleapis.com/auth/contacts.readonly",
               "https://www.googleapis.com/auth/directory.readonly"]
}

def authenticate():
    """Authenticate with Google API using OAuth."""
    creds = None
    token_path = os.path.expanduser(CONFIG["token_file"])

    # Check if we have a token file already
    if os.path.exists(token_path):
        with open(token_path, 'rb') as token:
            creds = pickle.load(token)

    # If credentials don't exist or are invalid, authenticate
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            credentials_path = os.path.expanduser(CONFIG["credentials_file"])
            flow = InstalledAppFlow.from_client_secrets_file(
                credentials_path, CONFIG["scopes"])
            creds = flow.run_local_server(port=0)

        # Save the credentials for the next run
        with open(token_path, 'wb') as token:
            pickle.dump(creds, token)

    return build('people', 'v1', credentials=creds)

def fetch_directory_contacts(service):
    """Fetch directory contacts visible to the user."""
    results = []
    next_page_token = None

    print("Fetching contacts from your directory...")

    # First try to get directory contacts (if you have access)
    try:
        while True:
            request = service.people().listDirectoryPeople(
                readMask='names,emailAddresses,organizations,phoneNumbers',
                sources=['DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE'],
                pageSize=1000,
                pageToken=next_page_token
            )

            response = request.execute()
            people = response.get('people', [])
            results.extend(people)

            next_page_token = response.get('nextPageToken')
            if not next_page_token:
                break

        print(f"Retrieved {len(results)} contacts from directory")
    except Exception as e:
        print(f"Could not access directory: {e}")
        print("Falling back to personal contacts...")

    # If directory access failed or returned no results, fall back to contacts
    if not results:
        next_page_token = None
        while True:
            request = service.people().connections().list(
                resourceName='people/me',
                pageSize=1000,
                personFields='names,emailAddresses,organizations,phoneNumbers',
                pageToken=next_page_token
            )

            response = request.execute()
            connections = response.get('connections', [])
            results.extend(connections)

            next_page_token = response.get('nextPageToken')
            if not next_page_token:
                break

        print(f"Retrieved {len(results)} personal contacts")

    return results

def convert_to_emailbook_format(contacts):
    """Convert Google contacts to emailbook format."""
    emailbook_entries = []

    for contact in contacts:
        # Skip contacts without email
        emails = contact.get('emailAddresses', [])
        if not emails:
            continue

        # Get name
        names = contact.get('names', [])
        full_name = ""
        if names:
            display_name = names[0].get('displayName', '')
            if display_name:
                full_name = display_name

        # If no name is available, use the email address
        email = emails[0].get('value', '')
        if not full_name and email:
            full_name = email.split('@')[0]

        # Create entry/ add to list
        entry = f"{full_name} <{email}>"
        emailbook_entries.append(entry)

    return emailbook_entries

def save_to_file(entries, output_file):
    """Save entries to emailbook file."""
    output_path = os.path.expanduser(output_file)
    with open(output_path, 'w') as f:
        for entry in entries:
            f.write(f"{entry}\n")

    print(f"Saved {len(entries)} entries to {output_file}")

def main():
    """Main function to run the conversion process."""
    parser = argparse.ArgumentParser(description="Convert Google Contacts to emailbook format")
    parser.add_argument("--output", help="Output file path", default=CONFIG["output_file"])
    args = parser.parse_args()

    CONFIG["output_file"] = args.output

    try:
        # Authenticate and get service
        service = authenticate()

        # Fetch contacts
        contacts = fetch_directory_contacts(service)

        # Convert to emailbook format
        emailbook_entries = convert_to_emailbook_format(contacts)

        # Save to file
        save_to_file(emailbook_entries, CONFIG["output_file"])

        return 0
    except Exception as e:
        print(f"Error: {e}")
        return 1

if __name__ == "__main__":
    exit(main())
