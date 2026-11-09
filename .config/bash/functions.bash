# --- GENERAL-PURPOSE SHELL FUNCTIONS (bash port of home/shell/functions.zsh) ---

# Omarchy defines `t` as an alias (attach || new -s Work). Remove it first,
# otherwise bash expands the alias inside the function definition below.
unalias t 2>/dev/null

# Attach to a named tmux session (default 1); create if absent
# Usage: t [session_name]
t() {
  if [ $# -eq 0 ]; then
    tmux new-session -As 1
  else
    tmux new-session -As "$1"
  fi
}

# Change directory with zoxide, then list contents with eza
# Usage: zl [path]
zl() {
  z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Make and change to a directory
# Usage: mkcd <directory>
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Omarchy defines `r` as an alias (rails); remove it so this function wins.
unalias r 2>/dev/null

# Recall the last command's output (filtered by PATTERN) to the clipboard
# Usage: r [PATTERN] [-p]   (-p prints to stdout instead)
r() {
  local pattern="$1"
  local print_only="$2"

  if [[ "$pattern" == "--help" || "$pattern" == "-h" ]]; then
    echo "Usage: r [PATTERN] [-p]"
    echo "Recall last command output and copy to clipboard"
    echo
    echo "Options:"
    echo "  PATTERN     Filter output using pattern"
    echo "  -p          Print to stdout instead of copying to clipboard"
    echo "  --help, -h  Show this help message"
    return 0
  fi

  local output_cmd="wl-copy"
  if [[ "$print_only" == "-p" ]]; then
    output_cmd="cat"
  fi

  if [ -z "$pattern" ]; then
    fc -ln -1 | $output_cmd
  else
    fc -ln -1 | grep "$pattern" | $output_cmd
  fi
}

# --- KETCH ---
# ketch search as JSON, pretty-printed
ksj() {
  ketch search --json "$@" | jq
}

# ketch code search (github backend) as JSON, pretty-printed
kcj() {
  ketch code -b github --json "$@" | jq
}

# Quick tree view
# Usage: qtree [directory] [depth]
qtree() {
  local dir="${1:-.}"
  local depth="${2:-2}"
  command tree "$dir" -L "$depth" -CF
}

# Yazi file manager; cd to the directory yazi ended in
# Usage: y [arguments]
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
