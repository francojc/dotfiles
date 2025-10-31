{...}: let
  clientId = builtins.getEnv "REDDIT_CLIENT_ID";
  clientSecret = builtins.getEnv "REDDIT_CLIENT_SECRET";
in {
  xdg.configFile."reddix/config.yaml" = {
    text = ''
      # Reddix configuration
      # Managed by Nix - see ~/.dotfiles/.config/nix/home/reddix.nix
      reddit:
        client_id: "${clientId}"
        client_secret: "${clientSecret}"
        user_agent: "reddix/0.1 (+https://github.com/ck-zhang/reddix)"
        scopes:
          - identity
          - mysubreddits
          - read
          - vote
          - subscribe
        redirect_uri: "http://127.0.0.1:65010/reddix/callback"
      ui:
        theme: default
      media:
        cache_dir: null
        max_size_bytes: 524288000
        default_ttl: "6h"
        workers: 2
      player:
        video_command:
          - mpv
          - --fs
          - "%URL%"
        video_detach: true
    '';
  };
}
