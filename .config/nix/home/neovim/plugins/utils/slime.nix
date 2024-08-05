{
  plugins.vim-slime = {
    enable = true;
    settings = {
      target = "kitty";
      preserve_curpos = false;
      bracketed_paste = true;
      default_config = {
        socket_name = "default";
        relative_pane = "right";
      };
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<C-c>";
      action = "<Plug>SlimeParagraphSend<CR>";
      options = { desc = "Send region to target"; };
    }
    {
      mode = "v";
      key = "<C-CR>";
      action = "<Plug>SlimeRegionSend<CR>";
      options = { desc = "Send region to target"; };
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = "<Cmd>SlimeConfig<CR>";
      options = { desc = "Open slime config"; };
    }
  ];
}
