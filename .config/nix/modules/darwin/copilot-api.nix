{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.custom.services.copilotApi;
  home = "/Users/${username}";
in {
  options.custom.services.copilotApi = {
    enable = mkEnableOption "local GitHub Copilot API proxy";

    executable = mkOption {
      type = types.str;
      default = "${home}/.npm-global/bin/copilot-api";
      description = "Path to the copilot-api executable.";
    };

    port = mkOption {
      type = types.int;
      default = 4141;
      description = "Loopback port for the copilot-api server.";
    };

    rateLimitSeconds = mkOption {
      type = types.int;
      default = 2;
      description = "Minimum delay between completion requests.";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents."copilot-api" = {
      serviceConfig = {
        Label = "com.github.copilot-api";
        ProgramArguments = [
          cfg.executable
          "start"
          "--port"
          (toString cfg.port)
          "--rate-limit"
          (toString cfg.rateLimitSeconds)
          "--wait"
        ];
        WorkingDirectory = home;
        StandardOutPath = "${home}/.local/state/copilot-api/stdout.log";
        StandardErrorPath = "${home}/.local/state/copilot-api/stderr.log";
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        ThrottleInterval = 30;
        EnvironmentVariables = {
          HOME = home;
          HOST = "127.0.0.1";
          PATH = "/etc/profiles/per-user/${username}/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };

    system.activationScripts.copilotApi.text = ''
      /usr/bin/install -d -m 700 -o ${username} -g staff "${home}/.local/state/copilot-api"
    '';
  };
}
