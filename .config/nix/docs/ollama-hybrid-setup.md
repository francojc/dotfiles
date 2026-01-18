# Ollama Hybrid Setup Documentation

## Overview

This system uses a **hybrid Homebrew + Nix approach** for running Ollama:

- **Service**: Managed by macOS LaunchAgent (Homebrew binary)
- **Configuration**: Declared in Nix (but requires manual sync)

## Why This Approach?

- Uses latest Ollama from Homebrew (faster updates than nixpkgs)
- Declarative configuration in Nix
- Service accessible via Tailscale network

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Nix Configuration                               │
│ hosts/Mac-Minicore/default.nix                  │
│                                                 │
│ - Declares all settings                         │
│ - Sets system environment variables             │
│ - Does NOT manage the service                   │
└─────────────────────────────────────────────────┘
                    ↓
              (manual sync)
                    ↓
┌─────────────────────────────────────────────────┐
│ LaunchAgent Plist                               │
│ ~/Library/LaunchAgents/com.github.ollama.plist  │
│                                                 │
│ - Runs /opt/homebrew/bin/ollama serve           │
│ - Uses environment variables from dict          │
│ - Isolated from system environment              │
└─────────────────────────────────────────────────┘
```

## Configuration Files

### Primary Configuration
- **Nix**: `~/.dotfiles/.config/nix/hosts/Mac-Minicore/default.nix`
- **Plist**: `~/Library/LaunchAgents/com.github.ollama.plist`
- **Module**: `~/.dotfiles/.config/nix/modules/darwin/ollama.nix`

## Current Settings

```nix
custom.services.ollama = {
  enable = true;
  port = 11434;
  host = "0.0.0.0";                    # Network accessible
  flashAttention = true;                # Performance optimization
  kvCacheType = "q8_0";                 # Memory efficiency (8-bit KV cache)
  extraEnvironment = {
    OLLAMA_NUM_PARALLEL = "4";          # Handle 4 concurrent requests
    OLLAMA_NUM_CTX = "8192";            # 8192 token context window
  };
};
```

## Changing Ollama Configuration

**IMPORTANT**: Changes require manual synchronization between Nix and plist.

### Step-by-Step Process

1. **Update Nix Configuration**

   Edit `~/.dotfiles/.config/nix/hosts/Mac-Minicore/default.nix`:
   ```nix
   custom.services.ollama = {
     # ... modify settings here ...
     extraEnvironment = {
       OLLAMA_NUM_PARALLEL = "8";  # example change
     };
   };
   ```

2. **Apply Nix Configuration**

   ```bash
   darwin-rebuild switch
   ```

3. **Update LaunchAgent Plist**

   Edit `~/Library/LaunchAgents/com.github.ollama.plist`:

   Update the `<key>EnvironmentVariables</key>` dict to include:

   ```xml
   <key>EnvironmentVariables</key>
   <dict>
       <key>OLLAMA_HOST</key>
       <string>0.0.0.0:11434</string>
       <key>OLLAMA_MODELS</key>
       <string>/Users/jeridf/.ollama/models</string>
       <key>OLLAMA_FLASH_ATTENTION</key>
       <string>1</string>
       <key>OLLAMA_KV_CACHE_TYPE</key>
       <string>q8_0</string>
       <!-- Add all extraEnvironment variables -->
       <key>OLLAMA_NUM_PARALLEL</key>
       <string>8</string>  <!-- updated value -->
       <key>OLLAMA_NUM_CTX</key>
       <string>8192</string>
   </dict>
   ```

4. **Reload LaunchAgent**

   ```bash
   launchctl unload ~/Library/LaunchAgents/com.github.ollama.plist
   launchctl load ~/Library/LaunchAgents/com.github.ollama.plist
   ```

   Alternative (if above doesn't work):
   ```bash
   launchctl bootout gui/$(id -u)/com.github.ollama
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.github.ollama.plist
   ```

5. **Verify Changes**

   ```bash
   # Check service is running
   launchctl list | grep ollama

   # Verify process
   ps aux | grep ollama | grep -v grep

   # Test API
   curl http://localhost:11434/api/tags
   ```

## Environment Variable Mapping

| Nix Config | Environment Variable | plist Value |
|-----------|---------------------|-------------|
| `host:port` | `OLLAMA_HOST` | `"0.0.0.0:11434"` |
| `modelsPath` | `OLLAMA_MODELS` | `"/Users/jeridf/.ollama/models"` |
| `flashAttention = true` | `OLLAMA_FLASH_ATTENTION` | `"1"` |
| `kvCacheType` | `OLLAMA_KV_CACHE_TYPE` | `"q8_0"` |
| `extraEnvironment.*` | `OLLAMA_*` | Corresponding value |

## Troubleshooting

### Service not starting

```bash
# Check launchd logs
log show --predicate 'process == "launchd"' --last 5m | grep ollama

# Verify plist syntax
plutil -lint ~/Library/LaunchAgents/com.github.ollama.plist
```

### Environment variables not taking effect

```bash
# Check running process environment
ps eww $(pgrep ollama) | tr ' ' '\n' | grep OLLAMA
```

### Port already in use

```bash
# Find what's using port 11434
lsof -nP -iTCP:11434
```

## Network Access

The service is configured to listen on `0.0.0.0:11434`, making it accessible via:

- **Local**: `http://localhost:11434`
- **Tailscale**: `http://mac-minicore.gerbil-matrix.ts.net:11434`

## Performance Notes

- **Context Window (8192)**: Uses ~4x more memory per request than default (2048)
- **Parallel Requests (4)**: Can handle 4 simultaneous requests
- **Flash Attention**: Reduces memory usage and speeds up inference
- **Q8_0 KV Cache**: 8-bit quantization saves ~50% memory vs F16

## Future Improvements

To eliminate manual sync, consider:

1. **Script-based generation**: Create a script that generates the plist from Nix config
2. **Full nix-darwin service**: Use the `ollama-back.nix` approach (see `modules/darwin/apps.nix:31`)

## Related Files

- `modules/darwin/ollama.nix` - Main Ollama module
- `modules/darwin/ollama-back.nix` - Backup of full nix-darwin service approach
- `modules/darwin/apps.nix:31` - Reference to "temporary replacement" comment

## Last Updated

2026-01-18 - Initial hybrid setup documented
