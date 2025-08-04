# Gemini Flash MCP Server for opencode

A Model Context Protocol (MCP) server that adds Gemini Flash image generation capabilities to opencode.

## Features

- Generate images using Google's Gemini 2.0 Flash model
- Automatic file naming with timestamps
- Error handling and validation
- Base64 image decoding and saving

## Prerequisites

- Node.js (v18 or higher)
- opencode installed
- Google Gemini API key

## Installation

1. **Clone or copy the server files:**
   ```bash
   # Files are already created in: /Users/jeridf/.dotfiles/.bin/gemini-mcp-server/
   cd gemini-mcp-server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up your Google Gemini API key:**
   - Get your API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
   - You can set it in the opencode config or as an environment variable

## Configuration

Add the MCP server to your opencode configuration file (`opencode.json` in your project root):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "gemini-image-generator": {
      "type": "local",
      "command": ["node", "/Users/jeridf/.dotfiles/.bin/gemini-mcp-server/server.js"],
      "enabled": true,
      "environment": {
        "GEMINI_API_KEY": "your_gemini_api_key_here"
      }
    }
  }
}
```

**Alternative:** Set your API key as an environment variable:
```bash
export GEMINI_API_KEY="your_gemini_api_key_here"
```

## Usage

Once configured, the `generate_image` tool will be available in opencode. You can use it like this:

**In opencode chat:**
```
Generate an image of a futuristic city at sunset with flying cars
```

**With specific parameters:**
```
Generate an image of a serene mountain landscape
```

### Tool Parameters

- `prompt` (required): Text description of the image to generate
- `output_dir` (optional): Directory to save images (default: `./generated_images`)

## Generated Images

Images are saved with descriptive filenames in the format:
```
gemini_[prompt_snippet]_[timestamp].png
```

Example: `gemini_futuristic_city_sunset_20240126_143022.png`

## Files Structure

```
gemini-mcp-server/
├── server.js              # MCP server implementation
├── generate-image.sh      # Shell script for Gemini API calls
├── package.json           # Node.js dependencies
├── example-opencode.json  # Example configuration
└── README.md             # This file
```

## Troubleshooting

**"GEMINI_API_KEY environment variable is required":**
- Ensure your API key is set in the opencode config or as an environment variable

**"Error from Gemini API":**
- Check your API key is valid and has sufficient quota
- Verify the prompt doesn't violate Google's content policy

**"Command not found" errors:**
- Ensure Node.js is installed and accessible
- Verify the path to `server.js` is correct in your opencode config

**Permission errors:**
- Make sure `generate-image.sh` is executable: `chmod +x generate-image.sh`

## Cost Considerations

Gemini 2.0 Flash image generation is currently free during the preview period.

Monitor your usage on the [Google AI Studio](https://aistudio.google.com/app/apikey).

## License

MIT