#!/usr/bin/env bash

# Common helpers for scripts in ~/.dotfiles/.bin
# Language: Bash (POSIX-friendly where practical)
# Style: 2 spaces indentation
# Behavior: consistent flags, NO_COLOR support, logging, dry-run, -C dir

set -Eeuo pipefail
IFS=$' \t\n'

# Version for the helpers (referenced by scripts if needed)
COMMON_SH_VERSION="0.1.0"

# Global flags (scripts may read these)
DRY_RUN=${DRY_RUN:-0}
VERBOSE=${VERBOSE:-0}
QUIET=${QUIET:-0}
CHANGE_DIR=""
SCRIPT_VERSION="0.0.0"
SCRIPT_NAME="${SCRIPT_NAME:-$(basename "${0:-script}")}"

# Color handling (respect NO_COLOR)
_color_enabled() {
  # Enable color when:
  # - NO_COLOR is not set, and
  # - stdout is a TTY OR FORCE_COLOR is set (any non-empty value)
  if [[ -n "${NO_COLOR:-}" ]]; then
    return 1
  fi
  if [[ -n "${FORCE_COLOR:-}" ]]; then
    return 0
  fi
  [[ -t 1 ]] || return 1
  return 0
}

if _color_enabled; then
  C_RESET=$'\033[0m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
else
  C_RESET=''
  C_DIM=''
  C_RED=''
  C_YELLOW=''
  C_BLUE=''
fi

_ts() {
  date "+%Y-%m-%dT%H:%M:%S%z"
}

log_info() {
  [[ "$QUIET" -eq 1 ]] && return 0
  printf "%s%sINFO%s %s\n" "$C_BLUE" "$C_DIM" "$C_RESET" "$*"
}

log_warn() {
  printf "%sWARN%s %s\n" "$C_YELLOW" "$C_RESET" "$*" 1>&2
}

log_error() {
  printf "%sERROR%s %s\n" "$C_RED" "$C_RESET" "$*" 1>&2
}

die() {
  log_error "$*"
  exit 1
}

require() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
  done
}

run() {
  # Run a command (show when dry-run)
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "+ %s\n" "$*"
    return 0
  fi
  "$@"
}

# Transform a small set of long options into short ones for getopts
# Usage: set -- $(canonicalize_long_opts "$@")
canonicalize_long_opts() {
  local out=()
  while (($#)); do
    case "$1" in
      --help) out+=("-h") ;;
      --version) out+=("--version") ;;
      --verbose) out+=("-v") ;;
      --quiet) out+=("-q") ;;
      --dry-run) out+=("-n") ;;
      --chdir|--cd) shift; out+=("-C" "$1") ;;
      --) out+=("--"); shift; out+=("$@"); break ;;
      *) out+=("$1") ;;
    esac
    shift || true
  done
  printf '%s\n' "${out[@]}"
}

# Parse common flags: -h -v -q -n -C DIR and --version
# Leaves non-option args in "$@" for caller after a "--" marker if they need.
parse_common_args() {
  local OPTIND=1 opt
  while getopts ":hvnqC:-:" opt; do
    case "$opt" in
      h) SHOW_HELP=1 ;;
      v) VERBOSE=$((VERBOSE+1)) ;;
      q) QUIET=1 ;;
      n) DRY_RUN=1 ;;
      C) CHANGE_DIR="$OPTARG" ;;
      -) case "$OPTARG" in
           version) SHOW_VERSION=1 ;;
           *) die "Unknown long option --$OPTARG" ;;
         esac ;;
      :) die "Option -$OPTARG requires an argument" ;;
      \?) die "Unknown option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND-1)) || true
  # If CHANGE_DIR specified, apply it now for the caller
  if [[ -n "$CHANGE_DIR" ]]; then
    [[ -d "$CHANGE_DIR" ]] || die "Directory not found: $CHANGE_DIR"
    cd "$CHANGE_DIR"
  fi
  # Export values for caller
  export DRY_RUN VERBOSE QUIET CHANGE_DIR SHOW_HELP SHOW_VERSION
  # Echo back remaining args so caller can capture with eval/set -- pattern if desired
  printf '%s\n' "$@"
}

print_version() {
  printf "%s %s\n" "$SCRIPT_NAME" "${SCRIPT_VERSION:-0.0.0}"
}

on_err() {
  local exit_code=$?
  log_error "Command failed (exit $exit_code). At: ${BASH_SOURCE[1]}:${BASH_LINENO[0]} -> '${BASH_COMMAND}'"
  exit "$exit_code"
}

trap on_err ERR
