{
  hostname,
  ...
}: {
  xdg.configFile."ghostty/config" = {
    text = ''
      # Ghostty config
      
      # UI
      font-family = "Aporetic Sans Mono"
      font-size = ${toString (
        if hostname == "Mac-Minicore" then 30
        else if hostname == "Macbook-Airborne" then 16
        else 16
      )}
      cursor-color = #FF2557
      cursor-style = bar
      adjust-cursor-thickness = 2
      mouse-hide-while-typing = true
      
      # Tabs and windows
      # window-padding-x = 5
      # window-padding-y = 3
      window-padding-balance = true
      
      macos-titlebar-style = hidden
      macos-window-shadow = false
      macos-icon = custom-style
      macos-icon-frame = plastic
      macos-icon-ghost-color = #FF2557
      
      # Theme
      # theme = nightfox
      theme = GruvboxDarkHard
      # theme = Arthur
      # theme = Spacedust
      # theme = BirdsOfParadise
      
      # Keybindings
      keybind = alt+m=text: |>
      keybind = alt+-=text: <-
      
      macos-option-as-alt = right
      
      # Keybinds
      
      keybind = global:ctrl+`=toggle_quick_terminal
      keybind = shift+enter=text:\n
    '';
  };
}