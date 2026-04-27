{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.custom.services.llamaFim;
in {
  options.custom.services.llamaFim = {
    enable = mkEnableOption "llama.cpp FIM server";

    scriptPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/scripts/start-llama-fim.sh";
      description = "Path to FIM startup script";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp";
      description = "Working directory for the FIM server";
    };

    stdoutPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/fim-stdout.log";
      description = "Stdout log path";
    };

    stderrPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/logs/fim-stderr.log";
      description = "Stderr log path";
    };

    nice = mkOption {
      type = types.int;
      default = -5;
      description = "Process niceness";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents."llama-fim" = {
      serviceConfig = {
        Label = "com.llama.fim-server";
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

    system.activationScripts.llamaFim = {
      text = ''
        mkdir -p "/Users/${username}/.llama.cpp/logs"
        chown ${username}:staff "/Users/${username}/.llama.cpp/logs"
      '';
    };
  };
}
