#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

class DalleServer {
  constructor() {
    this.server = new Server(
      {
        name: 'dalle-image-generator',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    
    this.server.onerror = (error) => console.error('[MCP Error]', error);
    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'generate_image',
            description: 'Generate an image using DALL-E 3',
            inputSchema: {
              type: 'object',
              properties: {
                prompt: {
                  type: 'string',
                  description: 'The text prompt describing the image to generate',
                },
                size: {
                  type: 'string',
                  description: 'Image size',
                  enum: ['1024x1024', '1024x1792', '1792x1024'],
                  default: '1024x1024',
                },
                quality: {
                  type: 'string',
                  description: 'Image quality',
                  enum: ['standard', 'hd'],
                  default: 'standard',
                },
                output_dir: {
                  type: 'string',
                  description: 'Directory to save the generated image',
                  default: './generated_images',
                },
              },
              required: ['prompt'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      if (name === 'generate_image') {
        try {
          const { prompt, size = '1024x1024', quality = 'standard', output_dir = './generated_images' } = args;

          if (!prompt) {
            throw new Error('Prompt is required');
          }

          const scriptPath = join(__dirname, 'generate-image.sh');
          const command = `"${scriptPath}" "${prompt}" "${size}" "${quality}" "${output_dir}"`;
          
          const result = execSync(command, { 
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
          });

          const imagePath = result.trim();
          
          return {
            content: [
              {
                type: 'text',
                text: `Successfully generated image using DALL-E 3!\n\nPrompt: ${prompt}\nSize: ${size}\nQuality: ${quality}\nSaved to: ${imagePath}`,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Error generating image: ${error.message}`,
              },
            ],
            isError: true,
          };
        }
      }

      throw new Error(`Unknown tool: ${name}`);
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('DALL-E MCP server running on stdio');
  }
}

const server = new DalleServer();
server.run().catch(console.error);