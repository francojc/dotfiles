{ ...}:
{
  programs.nixvim = {
  plugins.snacks = {
    settings = {
      git.enabled = true;
      gitbrowse.enabled = true;
      };
    };
  };
}
