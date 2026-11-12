# --- FZF (bash port of home/shell/fzf.zsh) ---
# FZF_DEFAULT_COMMAND is exported from env.bash.
# Note: Ctrl-R is bound to atuin (integrations.bash), so FZF_CTRL_R_OPTS only
# applies if atuin is absent.

# Vague-inspired color theme (Nightfox alternative: see git history).
#   fg/fg+ #cdcdcd text   bg #141415     bg+ #252530 line
#   hl #df6882 error      hl+ #c3c3d5 property
#   info #7e98e8 hint     prompt #90a0b5 operator   pointer #c296eb lavender
#   marker #e0a363 number spinner #6e94b2 keyword   header #9bb4bc type
_fzf_colors="--color=fg:#cdcdcd,bg:#141415,hl:#df6882,fg+:#cdcdcd,bg+:#252530,hl+:#c3c3d5,info:#7e98e8,prompt:#90a0b5,pointer:#c296eb,marker:#e0a363,spinner:#6e94b2,header:#9bb4bc"

# Options shared by CTRL-R and CTRL-T
_fzf_common_opts="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-g:reload:rg --files --no-ignore'
    --bind 'ctrl-/:toggle-preview'
"

export FZF_DEFAULT_OPTS="
    --height 60%
    --layout=reverse
    --border
    --prompt='Search: ' $_fzf_colors
    --bind 'ctrl-p:up,ctrl-n:down'
    --preview 'bat -n --color=always {}'
"

export FZF_CTRL_R_OPTS="
    $_fzf_common_opts
    --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --color header:italic
    --header 'Press Ctrl-y to copy command onto clipboard'
"

export FZF_CTRL_T_OPTS="
    $_fzf_common_opts
    --bind 'ctrl-/:change-preview-window(down|hidden)'
"

export FZF_ALT_C_OPTS="
    --walker-skip .git
    --preview 'tree -C {}'
    --bind 'ctrl-g:reload:rg --files --no-ignore'
"

unset _fzf_colors _fzf_common_opts
