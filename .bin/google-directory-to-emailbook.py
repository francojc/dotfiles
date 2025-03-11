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
DOMAIN = 'university.edu'  # Replace with your actual university domain

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
