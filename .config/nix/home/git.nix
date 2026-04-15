{
  lib,
  pkgs,
  useremail,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      format = null;
    };
    settings = {
      user.name = "francojc";
      user.email = useremail;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      credential.helper =
        if pkgs.stdenv.isDarwin
        then "osxkeychain"
        else "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";

      # Diff and merge tools
      diff.tool = "diffview";
      difftool.nvimdiff.cmd = ''nvim -f -c "DiffviewOpen"'';
      difftool.prompt = false;
      merge.tool = "diffview";
      mergetool.diffview.cmd = ''nvim -f -c "DiffviewOpen"'';
      mergetool.prompt = false;
      mergetool.keepBackup = false;

      # Rebase and merge behavior
      rebase.autoStash = true;
      rebase.autoSquash = true;
      merge.conflictStyle = "zdiff3";

      # Branch tracking
      branch.autosetupmerge = "always";
      branch.autosetuprebase = "always";

      # Performance optimizations
      core.preloadindex = true;
      core.fscache = true;
      gc.auto = 256;

      # Better logging
      log.date = "iso";

      # Useful workflow settings
      status.showUntrackedFiles = "all";
      commit.verbose = true;
      help.autocorrect = 1;

      # Security
      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      # Git-specific workflow aliases
      alias = {
        unstage = "reset HEAD --"; # Unstage files; usage: git unstage <file>
        last = "log -1 HEAD --stat"; # Show last commit details; usage: git last
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side line-numbers decorations";
      syntax-theme = "gruvbox-dark";
      plus-style = "syntax #2d3016"; # Dark green background for additions
      minus-style = "syntax #3c1f1e"; # Dark red background for deletions
      line-numbers = true;
      line-numbers-minus-style = "#fb4934"; # Gruvbox bright red
      line-numbers-plus-style = "#b8bb26"; # Gruvbox bright green
      line-numbers-zero-style = "#928374"; # Gruvbox gray
      line-numbers-left-format = "{nm:>4}┊";
      line-numbers-right-format = "{np:>4}│";
      file-style = "bold #fabd2f"; # Gruvbox yellow for file names
      file-decoration-style = "#fe8019"; # Gruvbox orange for file decorations
      hunk-header-decoration-style = "#83a598 box"; # Gruvbox blue box
      hunk-header-file-style = "#fabd2f"; # Gruvbox yellow
      hunk-header-line-number-style = "#98971a"; # Gruvbox green
      hunk-header-style = "file line-number syntax";
      side-by-side = true;
      wrap-max-lines = "unlimited";
      wrap-left-symbol = "↵";
      wrap-right-symbol = "↴";
      navigate = true;
      light = false;
    };
  };
}
