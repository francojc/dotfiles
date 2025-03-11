#!/usr/bin/env python3
"""
Google People API to Emailbook Converter

This script fetches contacts from a Google Workspace Directory using the People API and converts them
to emailbook format (https://sr.ht/~maxgyver83/emailbook/).

Requirements:
- Google API Client: pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
- University Google Workspace account (regular member, no admin privileges required)

Set up instructions:
1. Enable the People API in the Google Cloud Console: https://console.cloud.google.com/apis/library/people.googleapis.com
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
SCOPES = ['https://www.googleapis.com/auth/directory.readonly']
TOKEN_FILE = os.path.expanduser('~/.config/google-directory-token.pickle')
CREDENTIALS_FILE = os.path.expanduser('~/.config/google-directory-credentials.json')
EMAILBOOK_DIR = os.path.expanduser('~/.local/share/emailbook')
EMAILBOOK_FILE = os.path.join(EMAILBOOK_DIR, 'emails')

# Your university's domain
DOMAIN = 'wfu.edu'  # Replace with your actual university domain

def get_people_service():
    """
    Authenticate with Google and return a service object for the People API.
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
                    f"Credentials file not found at {CREDENTIALS_FILE}\n"
                    "1. Go to https://console.cloud.google.com/apis/credentials\n"
                    "2. Create OAuth 2.0 Client IDs credentials\n"
                    "3. Download as JSON and place in above path"
                )

            flow = InstalledAppFlow.from_client_secrets_file(
                CREDENTIALS_FILE, 
                SCOPES,
                redirect_uri='urn:ietf:wg:oauth:2.0:oob'  # Use out-of-band flow
            )
            creds = flow.run_local_server(
                port=0,
                authorization_prompt_message='Please visit this URL to authorize access: {url}',
                success_message='Authentication complete! You may close this window.',
                open_browser=False
            )

        # Verify domain membership
        if creds.id_token and not creds.id_token.get('email', '').lower().endswith(f'@{DOMAIN}'):
            raise PermissionError(
                f"Account must be part of {DOMAIN} organization.\n"
                f"Logged in as: {creds.id_token.get('email', 'unknown')}"
            )

        # Save the credentials for the next run
        with open(TOKEN_FILE, 'wb') as token:
            pickle.dump(creds, token)

    # Build and return the service
    service = build(
        'people', 
        'v1', 
        credentials=creds,
        # Add discovery service URL for directory access
        discoveryServiceUrl='https://people.googleapis.com/$discovery/rest?version=v1'
    )
    return service

def fetch_directory_contacts(service):
    """
    Fetch contacts from the Google People API.

    Args:
        service: Google People API service object

    Returns:
        List of people resources with name and email information
    """
    # Validate domain format first
    if not DOMAIN or DOMAIN == 'university.edu':
        raise ValueError("Domain not configured. Please run the setup script again.")
    
    if '.' not in DOMAIN:
        raise ValueError(f"Invalid domain format: {DOMAIN}. Use fully qualified domain like 'example.com'")

    contacts = []
    page_token = None
    
    try:
        # Keep fetching pages of results until there are no more
        while True:
            results = service.people().listDirectoryPeople(
                readMask='names,emailAddresses',
                sources=['DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE'],
                pageSize=1000,
                pageToken=page_token
            ).execute()
            
            people = results.get('people', [])
            contacts.extend(people)
            
            page_token = results.get('nextPageToken')
            if not page_token:
                break
    except Exception as e:
        raise RuntimeError(
            f"Failed to fetch directory contacts. Ensure:\n"
            f"1. Your organization shares directory information\n"
            f"2. You're using a {DOMAIN} account\n"
            f"3. People API is enabled\n"
            f"4. contacts.readonly scope is authorized\n"
            f"Original error: {str(e)}"
        ) from e

    return contacts

def write_emailbook_format(contacts, output_file):
    """
    Write contacts to emailbook format.

    The emailbook format is:
    name1 <email1>
    name2 <email2>
    ...

    Args:
        contacts: List of people resources from People API
        output_file: Path to output file
    """
    # Make sure the directory exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        for contact in contacts:
            # Get name from the names field (array of name objects)
            names = contact.get('names', [])
            full_name = ""
            if names:
                display_name = names[0].get('displayName', '')
                if display_name:
                    full_name = display_name
            
            # Get email addresses
            email_addresses = contact.get('emailAddresses', [])
            
            # Use email address as name if no name is provided
            if not full_name and email_addresses:
                full_name = email_addresses[0].get('value', '').split('@')[0]
            
            # Skip contacts without names or emails
            if not full_name or not email_addresses:
                continue
                
            # Write all email addresses
            for email_obj in email_addresses:
                email = email_obj.get('value', '')
                if email:
                    f.write(f"{full_name} <{email}>\n")

def main():
    """Main function to fetch and convert contacts."""
    print(f"Connecting to Google People API for domain {DOMAIN}...")

    try:
        # Authenticate and get the People API service
        service = get_people_service()

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
