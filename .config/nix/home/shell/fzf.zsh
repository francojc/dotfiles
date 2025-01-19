# FZF Base Configuration
export FZF_DEFAULT_COMMAND="rg --files"

# Gruvbox Dark Color Theme
fg="#ebdbb2"        # Light 1
bg="#282828"        # Dark 0
bg_highlight="#504945"  # Dark 2
yellow="#fabd2f"    # Bright Yellow
blue="#83a598"      # Bright Blue
aqua="#8ec07c"      # Bright Aqua
purple="#d3869b"    # Bright Purple
orange="#fe8019"    # Bright Orange

# Function to set color options
set_fzf_colors() {
    echo "--color=fg:$fg,bg:$bg,hl:$yellow,fg+:$fg,bg+:$bg_highlight,hl+:$orange,info:$blue,prompt:$aqua,pointer:$aqua,marker:$aqua,spinner:$yellow,header:$purple"
}

# Set FZF_DEFAULT_OPTS with base configuration and colors
FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --prompt='Search: ' $(set_fzf_colors)"

# Add key bindings
FZF_DEFAULT_OPTS+=" --bind 'ctrl-p:up,ctrl-n:down'"

# Export the final FZF_DEFAULT_OPTS
export FZF_DEFAULT_OPTS

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

