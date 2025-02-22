# FZF Base Configuration
export FZF_DEFAULT_COMMAND="rg --files"

# Nightfox-inspired Color Theme
# set_fzf_colors() {
#     local fg="#cdcecf"        # Light grey text
#     local bg="#192330"        # Deep navy base
#     local bg_highlight="#1d2a3f"  # Slightly lighter navy
#     local yellow="#e0c080"    # Muted gold
#     local blue="#719cd6"      # Soft periwinkle
#     local aqua="#7bd9ca"      # Teal accent
#     local purple="#c296eb"    # Lavender highlight
#     local orange="#ff9052"    # Warm coral
#     local pink="#d3869b"      # Blush pink
#
#     echo "--color=fg:$fg,bg:$bg,hl:$pink,fg+:$fg,bg+:$bg_highlight,hl+:$orange,info:$blue,prompt:$aqua,pointer:$purple,marker:$yellow,spinner:$yellow,header:$blue"
# }

# Vague-inspired Color Themej
set_fzf_colors() {
    local fg="#cdcdcd"         # Text (from fg in lua)
    local bg="#141415"         # Background (from bg in lua)
    local hl="#df6882"         # Error (from error in lua) - used for highlight
    local fg_plus="#cdcdcd"    # Text of selected item (same as fg)
    local bg_plus="#252530"    # Line (from line in lua) - Used for selected item background
    local hl_plus="#c3c3d5"    # Property (from property in lua) - Used for selected item highlight)
    local info="#7e98e8"      # Hint (from hint in lua)
    local prompt="#90a0b5"      # Operator (from operator in lua)
    local pointer="#c296eb"    # Lavender
    local marker="#e0a363"      # Number (from number in lua)
    local spinner="#6e94b2"      # Keyword (from keyword in lua)
    local header="#9bb4bc"      # Type (from type in lua)


    echo "--color=fg:$fg,bg:$bg,hl:$hl,fg+:$fg_plus,bg+:$bg_plus,hl+:$hl_plus,info:$info,prompt:$prompt,pointer:$pointer,marker:$marker,spinner:$spinner,header:$header"
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

