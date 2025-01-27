# FZF Base Configuration
export FZF_DEFAULT_COMMAND="rg --files"

# Nightfox-inspired Color Theme
set_fzf_colors() {
    local fg="#cdcecf"        # Light grey text
    local bg="#192330"        # Deep navy base
    local bg_highlight="#1d2a3f"  # Slightly lighter navy
    local yellow="#e0c080"    # Muted gold
    local blue="#719cd6"      # Soft periwinkle
    local aqua="#7bd9ca"      # Teal accent
    local purple="#c296eb"    # Lavender highlight
    local orange="#ff9052"    # Warm coral
    local pink="#d3869b"      # Blush pink

    echo "--color=fg:$fg,bg:$bg,hl:$pink,fg+:$fg,bg+:$bg_highlight,hl+:$orange,info:$blue,prompt:$aqua,pointer:$purple,marker:$yellow,spinner:$yellow,header:$blue"
}

# Base FZF Options
base_fzf_opts="
    --height 60%
    --layout=reverse
    --border
    --prompt='Search: ' $(set_fzf_colors)
    --bind 'ctrl-p:up,ctrl-n:down'
    --preview 'bat -n --color=always {}'
"

# Common options for preview and reload
common_opts="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-g:reload:rg --files --no-ignore'
    --bind 'ctrl-/:toggle-preview'
"

# CTRL-R configuration
export FZF_CTRL_R_OPTS="
    $common_opts
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'Press Ctrl-y to copy command onto clipboard'
"

# CTRL-T configuration
export FZF_CTRL_T_OPTS="
    $common_opts
    --bind 'ctrl-/:change-preview-window(down|hidden)'
"

# ALT-C configuration
export FZF_ALT_C_OPTS="
    --walker-skip .git
    --preview 'tree -C {}'
    --bind 'ctrl-g:reload:rg --files --no-ignore'
"

# Export the final FZF_DEFAULT_OPTS
export FZF_DEFAULT_OPTS="$base_fzf_opts"

