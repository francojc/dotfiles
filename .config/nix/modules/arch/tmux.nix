# Arch / Omarchy-adjusted tmux configuration.
#
# This is the Arch counterpart to home/tmux.nix. Omarchy themes the *running*
# tmux server at runtime via `omarchy-theme-set-tmux` (it pushes theme env vars
# and `window-style`/`cursor-colour` with `tmux set-option`, and writes OSC
# sequences into panes). It does not rewrite ~/.config/tmux/tmux.conf. To avoid
# fighting that runtime theming, this module keeps the keybindings, plugins and
# non-color settings but drops the THEMING block and the themed status bar.
#
# Note: `omarchy refresh tmux` *does* overwrite ~/.config/tmux/tmux.conf with
# Omarchy's default, which would replace this Home Manager symlink. Do not run
# it while this module manages tmux.
{
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    prefix = "C-a";

    extraConfig = ''
      # -------------------------------------------------
      # GENERAL SETTINGS
      # -------------------------------------------------

      # Unbind default prefix and set new one
      unbind C-b
      bind C-a send-prefix

      # Clipboard support
      set -g set-clipboard on

      # True color support for modern terminals
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",*256col*:RGB"

      # Pane base index
      setw -g pane-base-index 1

      # Server behavior
      set -s focus-events on
      set -s extended-keys on
      set -s escape-time 0
      set -g detach-on-destroy off

      # For PI
      set -s extended-keys-format csi-u

      # Window behavior
      set -g renumber-windows on
      set-window-option -g automatic-rename on
      set-option -g set-titles on

      # Image preview for Yazi
      set -gq allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Misc settings
      set -g allow-rename off
      set -g visual-activity off
      set -g display-time 1500
      set -g status-keys vi

      # -------------------------------------------------
      # KEY BINDINGS
      # -------------------------------------------------

      # Global bindings
      bind R source-file ~/.config/tmux/tmux.conf \; display-message "TMUX config reloaded!"
      bind P paste-buffer
      bind S new-session

      # Copy mode bindings
      setw -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # Session bindings
      bind-key n switch-client -n   # Go to the next session
      bind-key p switch-client -p   # Go to the previous session
      bind-key a switch-client -l   # Toggle to the last session

      # Window bindings
      bind W new-window -c "#{pane_current_path}"
      bind -r Tab next-window

      # Select specific windows
      bind-key 1 select-window -t :1
      bind-key 2 select-window -t :2
      bind-key 3 select-window -t :3
      bind-key 4 select-window -t :4
      bind-key 5 select-window -t :5

      # Swap windows
      bind -r < swap-window -d -t -1
      bind -r > swap-window -d -t +1

      # Kill window
      bind q kill-window

      # Floating session popup (in current path), use detach to close
      bind-key f display-popup -w 80% -h 60% -E "tmux new-session -s popup -c '#{pane_current_path}' \\; set-option destroy-unattached on"

      # Popups
      # Obsidian vault popup which opens `~/Obsidian/Notes/Daily/{current_date}.md` in Neovim
      bind-key o display-popup -w 80% -h 60% -d ~/Obsidian/Notes -T "Obsidian Daily Note" -E "nvim ~/Obsidian/Notes/plan/daily/$(date +'%Y-%m-%d').md"

      # Floating Git status popup using lazygit
      bind-key g display-popup -w 80% -h 60% -d '#{pane_current_path}' -T "Git Status" -E lazygit

      # Floating calendar popup
      bind-key c display-popup -w 60% -h 40% -T "Calendar" -k "gcal -K .."

      # Jump to Pi agents awaiting attention
      bind-key N run-shell 'pi-waiting --last'
      bind-key C-n display-popup -w 90% -h 70% -T "Awaiting Pi agents" -E 'pi-waiting'

      # kill pane
      bind x kill-pane

      # Rename session/window
      bind \" command-prompt -p "rename-session:" "rename-session '%%'"
      bind \' command-prompt -p "rename window:" "rename-window %%"

      # Pane bindings - split panes (using original tmux.conf logic)
      bind h split-window -h -b -t:+0 -c "#{pane_current_path}"
      bind j split-window -v -c "#{pane_current_path}"
      bind k split-window -v -b -t:+0 -c "#{pane_current_path}"
      bind l split-window -h -c "#{pane_current_path}"

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Swap panes
      bind-key M command-prompt -p "move pane to:" "swap-pane -s '%%' -t ."

      # Join pane to current window
      bind ¡ choose-window 'join-pane -s "%%"'
    '';

    plugins = with pkgs.tmuxPlugins; [
      fzf-tmux-url
      vim-tmux-navigator
      yank
    ];
  };

  # Runtime dependencies for the tmux plugins above. Omarchy ships fzf and
  # wl-clipboard, but declaring them keeps the module self-contained.
  home.packages = with pkgs; [
    fzf
    wl-clipboard
  ];

  # Create empty directories with .keep files so other tooling
  # (e.g., the Obsidian popup) has somewhere to write.
  home.activation.createKeepFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.config/tmux" "$HOME/Obsidian/Notes"
    test -e "$HOME/.config/tmux/.keep" || : > "$HOME/.config/tmux/.keep"
    test -e "$HOME/Obsidian/Notes/.keep" || : > "$HOME/Obsidian/Notes/.keep"
  '';

  # Pi awaiting-agent switcher.
  home.file.".local/bin/pi-waiting" = {
    source = ../../home/scripts/pi-waiting;
    executable = true;
  };
}
