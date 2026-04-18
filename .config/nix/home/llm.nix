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

    # Local llama.cpp router models (OpenAI-compatible API on :8081)
    # Run once after rebuild:
    #   llm keys set local-router "no-key"
    #   llm keys set local-embed "no-key"

    - model_id: local/qwen3.5-9b
      model_name: Qwen3.5-9B-Q8_0
      api_base: "http://100.101.38.4:8081"
      api_key_name: local-router
      supports_tools: true

    - model_id: local/gpt-oss-20b
      model_name: gpt-oss-20b-Q8_0
      api_base: "http://100.101.38.4:8081"
      api_key_name: local-router
      supports_tools: true

    - model_id: local/gemma-4-e4b
      model_name: gemma-4-E4B-it-Q6_K
      api_base: "http://100.101.38.4:8081"
      api_key_name: local-router
      supports_tools: true

    - model_id: local/gemma-4-e2b
      model_name: gemma-4-E2B-it-Q8_0
      api_base: "http://100.101.38.4:8081"
      api_key_name: local-router
      supports_tools: true

    - model_id: local/qwen3.5-4b
      model_name: Qwen3.5-4B-Q8_0
      api_base: "http://100.101.38.4:8081"
      api_key_name: local-router
      supports_tools: true

    # Local llama.cpp embedding endpoint on :8082
    - model_id: local/nomic-embed
      model_name: nomic-embed-text-v1.5
      api_base: "http://100.101.38.4:8082"
      api_key_name: local-embed
      supports_tools: false
  '';
}
