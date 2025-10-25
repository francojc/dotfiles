{
  pkgs,
  theme,
  ...
}: {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
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

      # True color support and terminal overrides
      set -ga terminal-overrides "xterm-ghostty"

      # Pane base index
      setw -g pane-base-index 1

      # Server behavior
      set -s focus-events on
      set -s extended-keys on
      set -s escape-time 0
      set -g detach-on-destroy off

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

      # -------------------------------------------------
      # THEMING (using centralized theme)
      # -------------------------------------------------

      # Status bar
      set -g status on
      set -g status-position top # top/bottom
      set -g status-style bg='${theme.colors.bg1}',fg='${theme.colors.fg1}'
      set -g status-justify left

      # Status bar configuration with theme colors
      set -g status-left '#[fg=${theme.colors.accent},bg=default]   #S #[fg=${theme.colors.yellow},bg=default] ▌  '
      set -g status-left-length 50

      # Window status format with theme colors
      set -g window-status-format '#[fg=${theme.colors.bg3},bg=default] #I #[fg=${theme.colors.bg3},bg=default]#W'
      set -g window-status-current-format '#[fg=${theme.colors.yellow},bg=default] #I #[fg=${theme.colors.yellow}]#W'

      # Right side with theme colors
      set -g status-right '#[fg=${theme.colors.bright_red}]▌   #P #[fg=${theme.colors.accent}]▌   #h '
      set -g status-right-length 50

      # Pane border colors
      set -g pane-border-lines single
      set -g pane-border-style fg='${theme.colors.bg3}'
      set -g pane-active-border-style fg='${theme.colors.accent}'

      # Message colors
      set -g message-style bg='${theme.colors.accent}',fg='${theme.colors.bg0}'
      set -g message-command-style bg='${theme.colors.yellow}',fg='${theme.colors.bg0}'

      # Mode (copy mode) colors
      set -g mode-style bg='${theme.colors.accent}',fg='${theme.colors.bg0}'

      # Window status activity colors
      set -g window-status-activity-style bg='${theme.colors.yellow}',fg='${theme.colors.bg0}'
    '';

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = "";
      }
      {
        plugin = vim-tmux-navigator;
        extraConfig = "";
      }
      {
        plugin = fzf-tmux-url;
        extraConfig = "";
      }
    ];
  };

  # Create tmux config directory
  xdg.configFile."tmux/.keep".text = "";
}
