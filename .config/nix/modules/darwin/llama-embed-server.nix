{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.custom.services.llamaEmbed;
in {
  options.custom.services.llamaEmbed = {
    enable = mkEnableOption "llama.cpp embedding server";

    scriptPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/scripts/start-llama-embed.sh";
      description = "Path to embedding startup script";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp";
      description = "Working directory for the embedding server";
    };

    stdoutPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/embed-stdout.log";
      description = "Stdout log path";
    };

    stderrPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/embed-stderr.log";
      description = "Stderr log path";
    };

    nice = mkOption {
      type = types.int;
      default = -5;
      description = "Process niceness";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents."llama-embed" = {
      serviceConfig = {
        Label = "com.llama.embed-server";
        ProgramArguments = [cfg.scriptPath];
        WorkingDirectory = cfg.workingDirectory;
        StandardOutPath = cfg.stdoutPath;
        StandardErrorPath = cfg.stderrPath;
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ProcessType = "Interactive";
        Nice = cfg.nice;
        ThrottleInterval = 30;
        EnvironmentVariables = {
          PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };

    system.activationScripts.llamaEmbed = {
      text = ''
        mkdir -p "/Users/${username}/.llama.cpp/logs"
        chown ${username}:staff "/Users/${username}/.llama.cpp/logs"
      '';
    };
  };
}
