{
  lib,
  useremail,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "francojc";
    userEmail = useremail;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      credential.helper = "osxkeychain";

      # Diff and merge tools
      diff.tool = "nvimdiff";
      difftool.nvimdiff.cmd = "nvim -d $LOCAL $REMOTE";
      difftool.prompt = false;
      merge.tool = "nvimdiff";
      mergetool.nvimdiff.cmd = "nvim -d $LOCAL $REMOTE $MERGED -c 'wincmd w' -c 'wincmd J'";
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
      fetch.fsckobjects = true;
      receive.fsckObjects = true;

      # Git-specific workflow aliases
      alias = {
        wip = "!git add -A && git commit -m 'WIP'";
        unwip = "!git log -n 1 | grep -q -c 'WIP' && git reset HEAD~1";
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
        find = "!git log --pretty=format:'%h %cd %s [%an]' --date=short --follow --";
        lgs = "log --graph --oneline --decorate --all";
        recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'";
        unstage = "reset HEAD --";
        last = "log -1 HEAD --stat";
        amend = "commit --amend --no-edit";
      };
    };

    delta = {
      enable = true;
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
  };
}
