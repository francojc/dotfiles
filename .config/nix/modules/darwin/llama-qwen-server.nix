{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.custom.services.llamaQwen;
in {
  options.custom.services.llamaQwen = {
    enable = mkEnableOption "fixed-model Qwen chat server";

    scriptPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp/scripts/start-llama-qwen.sh";
      description = "Path to Qwen startup script";
    };

    workingDirectory = mkOption {
      type = types.str;
      default = "/Users/${username}/.llama.cpp";
      description = "Working directory for Qwen server";
    };

    nice = mkOption {
      type = types.int;
      default = -5;
      description = "Process niceness";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents."llama-qwen" = {
      serviceConfig = {
        Label = "com.llama.qwen-server";
        ProgramArguments = [cfg.scriptPath];
        WorkingDirectory = cfg.workingDirectory;
        StandardOutPath = "/Users/${username}/.llama.cpp/logs/qwen-stdout.log";
        StandardErrorPath = "/Users/${username}/.llama.cpp/logs/qwen-stderr.log";
        # Loaded at login but started only through llama-profile.sh, preventing Bonsai overlap.
        RunAtLoad = false;
        ProcessType = "Interactive";
        Nice = cfg.nice;
        ThrottleInterval = 30;
        EnvironmentVariables.PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };

    system.activationScripts.llamaQwen.text = ''
      mkdir -p "/Users/${username}/.llama.cpp/logs"
      chown ${username}:staff "/Users/${username}/.llama.cpp/logs"
    '';
  };
}
