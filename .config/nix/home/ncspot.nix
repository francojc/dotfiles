{
  theme,
  ...
}: {
  xdg.configFile."ncspot/config.toml" = {
    text = ''
      # NCSPOT
      # Core settings
      use_nerdfont = true
      gapless = true
      notify = true
      bitrate = 320

      # Audio/UI settings
      cover_max_scale = 2.0
      initial_screen = "queue"
      repeat = "off"
      flip_status_indicators = true
      hide_display_names = true

      [keybindings]
      # Navigation (Vim-like)
      "j" = "move down"
      "k" = "move up"
      "h" = "move left"
      "l" = "move right"
      "g" = "move top"
      "G" = "move bottom"

      # Playback controls
      "Space" = "playpause"
      "Enter" = "play"
      "n" = "next"
      "p" = "previous"

      # Volume control
      "+" = "volup 5"
      "-" = "voldown 5"
      "=" = "volup 5"

      # Seeking
      "Right" = "seek +5000"
      "Left" = "seek -5000"
      "Shift+Right" = "seek +30000"
      "Shift+Left" = "seek -30000"

      # Saving
      "s" = "save"

      # Modes
      "r" = "repeat"
      "z" = "shuffle"

      # Navigation/Search
      "/" = "search"
      "?" = "help"
      "o" = "open selected"

      # Quick tab switching
      "1" = "focus queue"
      "2" = "focus library"
      "3" = "focus search"

      # Utility
      "q" = "quit"
      "Esc" = "back"

      [theme]
      background = "${theme.ncspot.background}"
      primary = "${theme.ncspot.primary}"
      secondary = "${theme.ncspot.secondary}"
      title = "${theme.ncspot.title}"
      playing = "${theme.ncspot.playing}"
      playing_selected = "${theme.ncspot.playing_selected}"
      playing_bg = "${theme.ncspot.playing_bg}"
      highlight = "${theme.ncspot.highlight}"
      highlight_bg = "${theme.ncspot.highlight_bg}"
      error = "${theme.ncspot.error}"
      error_bg = "${theme.ncspot.error_bg}"
      statusbar = "${theme.ncspot.statusbar}"
      statusbar_progress = "${theme.ncspot.statusbar_progress}"
      statusbar_bg = "${theme.ncspot.statusbar_bg}"
      cmdline = "${theme.ncspot.cmdline}"
      cmdline_bg = "${theme.ncspot.cmdline_bg}"
      search_match = "${theme.ncspot.search_match}"
    '';
  };
}
