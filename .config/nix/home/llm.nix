# LLM configuration for GitHub Copilot via Tailscale
# Endpoint: https://copilot.gerbil-matrix.ts.net
# Auth: Tailscale network-level (no API key validated by server).
# A dummy key is required to satisfy the OpenAI client library.
# One-time setup: llm keys set copilot "no-key"
{...}: {
  home.file."Library/Application Support/io.datasette.llm/extra-openai-models.yaml".text = ''
    # GitHub Copilot — OpenAI-compatible models via Tailscale
    # Endpoint serves /chat/completions (not /responses).
    # Run once after rebuild: llm keys set copilot "no-key"

    - model_id: cop/claude-opus-4.6
      model_name: claude-opus-4.6
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/claude-sonnet-4.6
      model_name: claude-sonnet-4.6
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/claude-opus-4.5
      model_name: claude-opus-4.5
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/claude-sonnet-4.5
      model_name: claude-sonnet-4.5
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/claude-sonnet-4
      model_name: claude-sonnet-4
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/claude-haiku-4.5
      model_name: claude-haiku-4.5
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gemini-3.1-pro
      model_name: gemini-3.1-pro-preview
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gpt-5.1
      model_name: gpt-5.1
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gpt-5.2
      model_name: gpt-5.2
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gpt-5-mini
      model_name: gpt-5-mini
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gpt-4o
      model_name: gpt-4o-2024-11-20
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
      vision: true

    - model_id: cop/gpt-4o-mini
      model_name: gpt-4o-mini-2024-07-18
      api_base: "https://copilot.gerbil-matrix.ts.net"
      api_key_name: copilot
      supports_tools: true
  '';
}
