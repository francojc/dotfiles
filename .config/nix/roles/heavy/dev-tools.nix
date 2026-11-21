# Developer tooling role: language servers, formatters and dev utilities.
{pkgs, ...}: {
  home.packages =
    import ../../lib/packages/lsp.nix pkgs
    ++ import ../../lib/packages/dev.nix pkgs;

  # Modern R console (syntax highlighting, completion). Needs R on PATH.
  # Settings carried over from radian (.radian_profile). Config format is
  # unstable upstream; check ~/.config/arf/arf.toml after upgrades.
  programs.arf = {
    enable = true;
    settings = {
      editor = {
        mode = "vi";
        auto_match = false;
        highlight_matching_bracket = true;
        auto_suggestions = "all";
        # Setting key_map replaces arf's defaults, so keep alt-* too.
        key_map = {
          "alt-hyphen" = " <- ";
          "alt-p" = " |> ";
          "ctrl-o" = " <- ";
          "ctrl-p" = " |> ";
        };
      };
      prompt.vi.symbol = {
        insert = "> ";
        normal = "□ ";
        non_vi = "";
      };
      colors.prompt.vi = {
        insert = "Blue";
        normal = "Yellow";
      };
      r.auto_width = true;
      history.mode = "persistent";
    };
  };
}
