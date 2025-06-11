{ lib, useremail, ... }:
{
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
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
    };
    delta = {
      enable = true;
      options = {
        features = "side-by-side";
      };
    };
  };
}
