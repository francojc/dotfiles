# Local LLM host profile (Mac-Minicore only).
#
# The GPU (Metal) stays on macOS; the try-omarchy VM has no Vulkan. Servers
# bind to the Tailscale address, so Omarchy-Mini reaches them over the tailnet.
# Metal working-set budget is about 24 GiB; the three servers use about 22 GiB,
# so do not enlarge the FIM model or the chat context without checking the
# memory notes in ~/.llama.cpp/scripts/start-llama-*.sh.
{
  imports = [
    ../../modules/darwin/llama-qwen-server.nix
    ../../modules/darwin/llama-embed-server.nix
    ../../modules/darwin/llama-fim-server.nix
    ../../modules/darwin/copilot-api.nix
  ];

  custom.services = {
    copilotApi.enable = true;

    # Flagship Qwen3.6-35B-A3B-MTP chat endpoint on :8081
    llamaQwen = {
      enable = true;
      scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-qwen.sh";
    };

    # Dedicated embeddings endpoint on :8082
    llamaEmbed = {
      enable = true;
      scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-embed.sh";
    };

    # Fill-in-the-middle code completion endpoint on :8080
    llamaFim = {
      enable = true;
      scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-fim.sh";
    };
  };

  homebrew.brews = [
    "llama.cpp" # LLaMA model inference
    "ollama" # Ollama
    "hf" # huggingface cli
    "llmfit" # LLM system fit
    # Note: omlx installed via .dmg
  ];
}
