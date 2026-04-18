{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.custom.services.llamaRouter;
in {
  options.custom.services.llamaRouter = {
    enable = mkEnableOption "llama.cpp router server";

    scriptPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/scripts/start-llama-general.sh";
      description = "Path to router startup script";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp";
      description = "Working directory for the router server";
    };

    stdoutPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/router-stdout.log";
      description = "Stdout log path";
    };

    stderrPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/router-stderr.log";
      description = "Stderr log path";
    };

    nice = mkOption {
      type = types.int;
      default = -5;
      description = "Process niceness";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents."llama-router" = {
      serviceConfig = {
        Label = "com.llama.server";
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

    system.activationScripts.llamaRouter = {
      text = ''
        mkdir -p "/Users/${username}/.llama.cpp/logs"
        chown ${username}:staff "/Users/${username}/.llama.cpp/logs"
      '';
    };
  };
}
