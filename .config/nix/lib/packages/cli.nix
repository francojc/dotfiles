# Command-line utilities shared by every host. Items Omarchy already ships
# (bat, eza, fd, fzf, ripgrep, starship, tmux, zoxide, ...) are NOT here; they
# live in home/core.nix (Mac only) and are left to pacman on Omarchy.
pkgs:
with pkgs; [
  _7zz # Archive compression
  atuin # Shell history manager
  codesnap # CLI code snippet screenshot tool
  duf # Disk usage utility
  entr # Event notify tool
  mpack # encoding/decoding MIME types
  ncdu # Disk usage analyzer
  rclone # Cloud storage sync
  repgrep # ripgrep across files
  speedtest-cli # Internet speed test
  tirith # Terminal-based security for devs and AI
  tuicr # Git code review
  whosthere # Local Area Network discovery tool
  xan # data visualization from CSV files
  yazi-unwrapped # Terminal file manager
  yq-go # YAML processor
]
