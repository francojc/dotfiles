#!/usr/bin/env bash
# Description: This script is used to convert text to speech using the Eleven Labs API
# Usage: ./text2speech.sh -t "text to convert" [-k apiKey] [-r speech_rate] [-o output_file] [-v voice] [-h]
# Note: if not given, <apiKey> will be read from the environment variable ELEVENLABS_API_KEY
# Speech rate can be between 0.5 (slower) and 2.0 (faster). Default is 1.0
# Example: ./text2speech.sh -t "Hello world, this is a test" -k your_api_key -r 1.5 -o my_speech.mp3 -v male

# Function to display help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -t TEXT        Text to convert to speech (required)"
    echo "  -k KEY         API key (optional if ELEVENLABS_API_KEY env variable is set)"
    echo "  -r RATE        Speech rate between 0.5 and 2.0 (optional, default: 1.0)"
    echo "  -o FILE        Output filename (optional, default: output.mp3)"
    echo "  -v VOICE       Voice to use: 'male' for Leo or 'female' for Tatiana (optional, default: female)"
    echo "  -h, --help     Display this help message"
    echo
    echo "Examples:"
    echo "  $0 -t \"Hello world\""
    echo "  $0 -t \"Hello world\" -k your_api_key -r 1.5 -o my_speech.mp3 -v male"
    exit 0
}

# Initialize variables with defaults
speech_rate=1.0
text=""
apiKey=$ELEVENLABS_API_KEY
output_file="output.mp3"
voice_type="female"

# Parse command line arguments
while getopts ":t:k:r:o:v:h-:" opt; do
    case $opt in
        t) text="$OPTARG";;
        k) apiKey="$OPTARG";;
        r) speech_rate="$OPTARG";;
        o) output_file="$OPTARG";;
        v) voice_type="$OPTARG";;
        h) show_help;;
        -) case "${OPTARG}" in
               help) show_help;;
               *) echo "Invalid option: --${OPTARG}" >&2; exit 1;;
           esac;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        :) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
    esac
done

# Validate required arguments
if [ -z "$text" ]; then
    echo "Error: Text argument (-t) is required"
    echo "Use -h or --help for usage information"
    exit 1
fi

if [ -z "$apiKey" ]; then
    echo "Please provide the API key using -k flag or set the ELEVENLABS_API_KEY environment variable"
    exit 1
fi

# Validate speech rate is between 0.5 and 2.0
if (( $(echo "$speech_rate < 0.5" | bc -l) )) || (( $(echo "$speech_rate > 2.0" | bc -l) )); then
    echo "Speech rate must be between 0.5 and 2.0"
    exit 1
fi

# Set voice ID based on voice type
case "$voice_type" in
    "female")
        # Spanish: Tatiana (Neutral Spanish)
        voice_id="2rigMbVWLdqtBSCahJFX"
        ;;
    "male")
        # Spanish: Leo (Colombia)
        voice_id="Ux2YbCNfurnKHnzlBHGX"
        ;;
    *)
        echo "Invalid voice type. Use 'male' or 'female'"
        exit 1
        ;;
esac

# Make a POST request to the Eleven Labs API to convert the text to speech
# Save the result to a file named output.mp3
curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/$voice_id" \
     -H "xi-api-key: $apiKey" \
     -H "Content-Type: application/json" \
     -d "{
        \"text\": \"$text\",
        \"model_id\": \"eleven_flash_v2_5\"
      }" -o "$output_file"

if [ "$speech_rate" != "1.0" ]; then
    # Create a temporary file
    temp_file="${output_file%.*}_original.mp3"
    mv "$output_file" "$temp_file"

    # Use ffmpeg to adjust tempo and save to final output file
    ffmpeg -i "$temp_file" -filter:a "atempo=$speech_rate" -vn "$output_file" -y 2>/dev/null

    # Clean up temporary file
    rm "$temp_file"
fi

echo "Audio saved to $output_file"

