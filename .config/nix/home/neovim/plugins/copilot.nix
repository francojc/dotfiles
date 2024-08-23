{
  programs.nixvim = {
    plugins.copilot-vim = {
      enable = true;
    };
    plugins.copilot-chat = {
      enable = true;
      settings = {
        model = "gpt-4";
        temperature = 0.8;
      };
    };
  };
}
