# --- GENERAL-PURPOSE SHELL FUNCTIONS ---

# SSH connection helper
# Usage: ssh_connect [host] [user] - connects to SSH server with optional user override
ssh_connect() {
  local host="$1"
  local user="$2"
  [ -z "$user" ] && user="jeridf"
  TERM=xterm-256color ssh "$user@$host"
}

# Rsync files to a remote host (skips files newer on remote)
# Usage: syncr <remote> <local_path> <remote_path>
syncr() {
  local remote
  case "$1" in
    minicore) remote="jeridf@mac-minicore" ;;
    airborne) remote="francojc@macbook-airborne" ;;
    rover) remote="jeridf@mini-rover" ;;
    pi-meta) remote="root@pi-meta" ;;
    monitor-services) remote="root@monitor-services" ;;
    monitor-pi) remote="root@monitor-pi" ;;
    *)
      echo "Unknown remote: $1"
      echo "Available: minicore, airborne, rover, pi-meta, monitor-pi, monitor-services"
      echo "Usage: syncr <remote> <local_path> <remote_path>"
      return 1
      ;;
  esac
  if [[ -z "$2" || -z "$3" ]]; then
    echo "Usage: syncr <remote> <local_path> <remote_path>"
    return 1
  fi
  rsync -avu --exclude='.git' "$2" "$remote:$3"
}

# Attach to a named tmux session (1-based); create if absent
# Usage: t [session_name] - creates or attaches to session
t() {
  if [ $# -eq 0 ]; then
    tmux new-session -As 1
  else
    tmux new-session -As "$1"
  fi
}

# List directory contents after changing directory
# Usage: zl [path] - changes directory and lists contents with eza
function zl() {
  z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Make and change to a directory
# Usage: mkcd [directory] - creates directory and changes to it
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Recall last command output - Simplified
# Usage: r [PATTERN] [-p] - recalls last command output with optional filtering
function r() {
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

  local output_cmd="pbcopy"
  if [[ "$print_only" == "-p" ]]; then
    output_cmd="cat"
  fi

  if [ -z "$pattern" ]; then
    fc -ln -1 | $output_cmd
  else
    fc -ln -1 | grep "$pattern" | $output_cmd
  fi
}

# Quick tree view
# Usage: qtree [directory] [depth] - lists directory tree with custom depth
function qtree() {
  if [ -z "$1" ]; then
    DIR="."
  else
    DIR=$1
  fi
  if [ -z "$2" ]; then
    L=2
  else
    L=$2
  fi
  command tree $DIR -L $L -CF
}

# Yazi file manager with directory navigation
# Usage: y [arguments] - opens yazi file manager
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
