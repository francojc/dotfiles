{theme, ...}: {
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    
    extraConfig = ''
      # Theme colors from centralized theme
      set -g status-bg '${theme.colors.bg1}'
      set -g status-fg '${theme.colors.fg1}'
      set -g status-left-style bg='${theme.colors.bg2}',fg='${theme.colors.fg0}'
      set -g status-right-style bg='${theme.colors.bg2}',fg='${theme.colors.fg0}'
      
      # Window status colors
      set -g window-status-style bg='${theme.colors.bg1}',fg='${theme.colors.fg2}'
      set -g window-status-current-style bg='${theme.colors.accent}',fg='${theme.colors.bg0}'
      set -g window-status-activity-style bg='${theme.colors.yellow}',fg='${theme.colors.bg0}'
      
      # Pane border colors
      set -g pane-border-style fg='${theme.colors.bg3}'
      set -g pane-active-border-style fg='${theme.colors.accent}'
      
      # Message colors
      set -g message-style bg='${theme.colors.accent}',fg='${theme.colors.bg0}'
      set -g message-command-style bg='${theme.colors.yellow}',fg='${theme.colors.bg0}'
      
      # Mode (copy mode) colors
      set -g mode-style bg='${theme.colors.accent}',fg='${theme.colors.bg0}'
      
      # Status bar configuration
      set -g status-left '#[bg=${theme.colors.accent},fg=${theme.colors.bg0}] #S #[bg=${theme.colors.bg1},fg=${theme.colors.accent}]'
      set -g status-right '#[bg=${theme.colors.bg2},fg=${theme.colors.fg0}] %Y-%m-%d %H:%M #[bg=${theme.colors.accent},fg=${theme.colors.bg0}] #h '
      set -g status-left-length 20
      set -g status-right-length 40
      
      # Window status format
      set -g window-status-format ' #I:#W#{?window_flags,#{window_flags}, } '
      set -g window-status-current-format ' #I:#W#{?window_flags,#{window_flags}, } '
      
      # Enable focus events for vim
      set -g focus-events on
      
      # Reduce escape time for better vim experience
      set -sg escape-time 10
      
      # Enable true color support
      set -ga terminal-overrides ',*256col*:Tc'
      
      # Keybindings
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      
      # Split panes with | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Switch panes with vim-like keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Copy mode vi bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
  
  # Create tmux config directory
  xdg.configFile."tmux/.keep".text = "";
}