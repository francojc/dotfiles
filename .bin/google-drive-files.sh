#!/usr/bin/env bash

show_help() {
    cat << EOF
google-drive-files.sh - Open Google Drive files in browser

USAGE:
    google-drive-files.sh [--help|-h] <file>

DESCRIPTION:
    Opens Google Drive files (gdoc, gsheet, gslides) in the default browser
    by extracting the document ID from the file and opening the corresponding
    Google Drive URL.

    The script reads the 'doc_id' field from the file metadata and constructs
    the appropriate URL based on the file type.

SUPPORTED FILE TYPES:
    - gdoc: Google Documents
    - gsheet: Google Sheets
    - gslides: Google Slides

DEPENDENCIES:
    - grep: For text searching
    - sed: For text processing
    - open: macOS command to open URLs

EXAMPLES:
    google-drive-files.sh document.gdoc
    # Opens Google Document in browser

    google-drive-files.sh spreadsheet.gsheet
    # Opens Google Sheet in browser

    google-drive-files.sh presentation.gslides
    # Opens Google Slides in browser

    google-drive-files.sh --help
    # Show this help message

NOTES:
    - Files must contain valid 'doc_id' field
    - Requires internet connection
    - Uses default system browser
    - macOS specific (uses 'open' command)

EOF
}

# Check for help flags
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

# Function to extract the doc_id from the file
extract_doc_id() {
    local file=$1
    local doc_id=$(grep -o '"doc_id":"[^"]*' "$file" | sed 's/"doc_id":"//')
    echo "$doc_id"
}

# Check the file extension and open the corresponding URL
open_google_doc() {
    local file=$1
    local extension="${file##*.}"
    local doc_id=$(extract_doc_id "$file")

    if [ -z "$doc_id" ]; then
        echo "doc_id not found in $file"
        exit 1
    fi

    case $extension in
        gdoc)
            open "https://docs.google.com/document/d/$doc_id"
            ;;
        gsheet)
            open "https://docs.google.com/spreadsheets/d/$doc_id"
            ;;
        gslides)
            open "https://docs.google.com/presentation/d/$doc_id"
            ;;
        *)
            echo "Unsupported file type: $extension"
            exit 1
            ;;
    esac
}

# Call the function with the file as an argument
open_google_doc "$1"
