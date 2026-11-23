# Planning pipeline timers (gather + short draft) for the always-on host.
#
# Replaces the Mac-Minicore crontab documented in the vault at
# .pi/specs/planning-cron.md. Each unit runs
#   .pi/scripts/planning-cron.sh <job> [--prune]
# against the vault that Omarchy-Mini sees through the 9p mount.
#
# Prerequisites that Nix cannot provide:
# - `loginctl enable-linger <user>` (run once, needs root) so timers fire with
#   no session.
# - A gpg-agent that can answer `pass show API/BIFROST_VK` without a TTY.
{
  config,
  lib,
  pkgs,
  ...
}: let
  vault = "/mnt/mac/obsidian/notes";
  home = config.home.homeDirectory;

  # Home Manager services start with a bare PATH. mise shims carry node.
  path = lib.concatStringsSep ":" [
    "${home}/.bin"
    "${home}/.nix-profile/bin"
    "${home}/.local/share/mise/shims"
    "${home}/.local/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
  ];

  jobs = {
    # Sunday evening: drafts the following Mon-Sun.
    weekly = {
      calendar = "Sun *-*-* 18:00:00";
      args = "weekly --prune";
    };
    # 1st of the month; day-of-month, not "first Sunday", so it cannot skip.
    monthly = {
      calendar = "*-*-01 05:10:00";
      args = "monthly --prune";
    };
    daily = {
      calendar = "Mon..Fri *-*-* 05:20:00";
      args = "daily";
    };
  };
in {
  systemd.user.services = lib.mapAttrs' (name: job:
    lib.nameValuePair "pi-planning-${name}" {
      Unit = {
        Description = "Pi planning ${name} draft";
        # The vault lives on the Mac-backed 9p mount.
        RequiresMountsFor = vault;
      };
      Service = {
        Type = "oneshot";
        WorkingDirectory = vault;
        Environment = [
          "PATH=${path}"
          "PLANNING_VAULT=${vault}"
          "TZ=America/New_York"
          # Task source for the gather: mailbox.org CalDAV Tasks via ~/.bin/tasks-json.
          "REMINDERS_CMD=tasks-json"
        ];
        ExecStart = "${pkgs.bash}/bin/bash ${vault}/.pi/scripts/planning-cron.sh ${job.args}";
        TimeoutStartSec = "30min";
      };
    })
  jobs;

  systemd.user.timers = lib.mapAttrs' (name: job:
    lib.nameValuePair "pi-planning-${name}" {
      Unit.Description = "Pi planning ${name} schedule";
      Timer = {
        OnCalendar = job.calendar;
        # Fire at next boot if the host was down at the scheduled time.
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    })
  jobs;
}
