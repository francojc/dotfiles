# DALL-E MCP Server for opencode

A Model Context Protocol (MCP) server that adds DALL-E 3 image generation capabilities to opencode.

## Features

- Generate images using OpenAI's DALL-E 3 model
- Configurable image size (1024x1024, 1024x1792, 1792x1024)
- Quality options (standard, hd)
- Automatic file naming with timestamps
- Error handling and validation

## Prerequisites

- Node.js (v18 or higher)
- opencode installed
- OpenAI API key

## Installation

1. **Clone or copy the server files:**
   ```bash
   # Files are already created in: /Users/jeridf/.dotfiles/.bin/dalle-mcp-server/
   cd dalle-mcp-server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up your OpenAI API key:**
   - Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
   - You can set it in the opencode config or as an environment variable

## Configuration

Add the MCP server to your opencode configuration file (`opencode.json` in your project root):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dalle-image-generator": {
      "type": "local",
      "command": ["node", "/Users/jeridf/.dotfiles/.bin/dalle-mcp-server/server.js"],
      "enabled": true,
      "environment": {
        "OPENAI_API_KEY": "your_openai_api_key_here"
      }
    }
  }
}
```

**Alternative:** Set your API key as an environment variable:
```bash
export OPENAI_API_KEY="your_openai_api_key_here"
```

## Usage

Once configured, the `generate_image` tool will be available in opencode. You can use it like this:

**In opencode chat:**
```
Generate an image of a futuristic city at sunset with flying cars
```

**With specific parameters:**
```
Generate a high-quality 1792x1024 image of a serene mountain landscape
```

### Tool Parameters

- `prompt` (required): Text description of the image to generate
- `size` (optional): Image dimensions - `1024x1024`, `1024x1792`, or `1792x1024` (default: `1024x1024`)
- `quality` (optional): Image quality - `standard` or `hd` (default: `standard`)
- `output_dir` (optional): Directory to save images (default: `./generated_images`)

## Generated Images

Images are saved with descriptive filenames in the format:
```
dalle_[prompt_snippet]_[timestamp].png
```

Example: `dalle_futuristic_city_sunset_20240126_143022.png`

## Files Structure

```
dalle-mcp-server/
├── server.js              # MCP server implementation
├── generate-image.sh      # Shell script for DALL-E API calls
├── package.json           # Node.js dependencies
├── example-opencode.json  # Example configuration
└── README.md             # This file
```

## Troubleshooting

**"OPENAI_API_KEY environment variable is required":**
- Ensure your API key is set in the opencode config or as an environment variable

**"Error from OpenAI API":**
- Check your API key is valid and has sufficient credits
- Verify the prompt doesn't violate OpenAI's content policy

**"Command not found" errors:**
- Ensure Node.js is installed and accessible
- Verify the path to `server.js` is correct in your opencode config

**Permission errors:**
- Make sure `generate-image.sh` is executable: `chmod +x generate-image.sh`

## Cost Considerations

DALL-E 3 pricing (as of 2024):
- Standard quality (1024×1024): $0.040 per image
- Standard quality (1024×1792, 1792×1024): $0.080 per image  
- HD quality: $0.080 per image (1024×1024), $0.120 per image (1024×1792, 1792×1024)

Monitor your usage on the [OpenAI Platform](https://platform.openai.com/usage).

## License

MIT