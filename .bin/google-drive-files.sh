#!/usr/bin/env bash

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
