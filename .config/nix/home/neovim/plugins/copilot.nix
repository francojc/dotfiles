{
  programs.nixvim = {
    plugins.copilot-vim = {
      enable = true;
    };
    plugins.copilot-chat = {
      enable = true;
      settings = {
        answer_header = "## Assistant ───";
        question_header = "## Me ───";
        model = "gpt-4o";
        temperature = 0.3;
        mappings = {
          close = {
            insert = "<C-c>";
            normal = "q";
          };
        };
        window = {
          border = "single";
          width = 0.25;
        };
      };
    };
  };
}
