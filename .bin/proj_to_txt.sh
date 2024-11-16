#!/usr/bin/env bash

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Check if input directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' does not exist"
    exit 1
fi

# Check for required dependencies
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is required but not installed"
    exit 1
fi

if ! command -v pdftotext &> /dev/null; then
    echo "Error: pdftotext is required but not installed"
    exit 1
fi

# Get absolute path of input directory and create output directory name
input_dir=$(realpath "$1")
output_dir="${input_dir}_conv"

# Create output directory
mkdir -p "$output_dir"

# Function to process files
process_file() {
    local input_file="$1"
    local output_file="$2"
    local file_ext="${input_file##*.}"

    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$output_file")"

    # Convert based on file extension
    case "${file_ext,,}" in
        pdf)
            pdftotext "$input_file" "${output_file%.*}.txt"
            ;;
        docx|doc)
            pandoc "$input_file" -f "${file_ext}" -t markdown -o "${output_file%.*}.md"
            ;;
        *)
            cp "$input_file" "$output_file"
            ;;
    esac
}

# Process files recursively
find "$input_dir" -type f | while read -r file; do
    # Get relative path
    rel_path="${file#"$input_dir"/}"
    # Create output path
    output_path="$output_dir/$rel_path"
    # Process the file
    process_file "$file" "$output_path"
done

echo "Conversion complete. Output directory: $output_dir"

