#!/usr/bin/env bash 

# Description: Connects to the OpenRouter AI service providing input/output from many different AI models from one service.
# Usage: openroute.sh -p <prompt> -m <model> -a <attachment> -o <output.ext>. The prompt -p is the user instructions. The model is specified, -m as the org/model name (e.g. anthropic/claude-3.5-latest:free). The input -i can be a string or a file. The script will read the input from the file. The output will be sent to stdout unless the -o option is used and the file name and extension are specified.
# Defaults:
# -p: <no prompt>
# -m: google/gemini-2.5-pro-preview-03-25
# -a: <no attachment>
# -i: <no input file>
# -o: <no output file>
#
# Author: Jerid Francom/Assistant
#

# sample curl call from the OpenRouter API docs: 
#
# curl https://openrouter.ai/api/v1/chat/completions \
#   -H "Content-Type: application/json" \
#   -H "Authorization: Bearer $OPENROUTER_API_KEY" \
#   -d '{
#   "model": "meta-llama/llama-4-maverick:free",
#   "messages": [
#     {
#       "role": "user",
#       "content": [
#         {
#           "type": "text",
#           "text": "What is in this image?"
#         },
#         {
#           "type": "image_url",
#           "image_url": {
#             "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
#           }
#         }
#       ]
#     }
#   ]
#
# }'
