{
  plugins.image = {
    enable = true;
    backend = "kitty";
    integrations = {
      markdown = {
        enabled = true;
        filetypes = [ "markdown" "quarto" ];
        onlyRenderImageAtCursor = true;
      };
    };
  };
}
