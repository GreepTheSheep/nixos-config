{ config, lib, pkgs, ... }:

let
  cfg = config.nixos.system.serviceWatchdog;

  mkCheckScript =
    name: systemctl:
    pkgs.writeShellScript name ''
      ${lib.concatMapStringsSep "\n" (service: ''
        if ! ${systemctl} is-active --quiet ${lib.escapeShellArg service}; then
          echo "Service ${service} is not active, starting it..."
          ${systemctl} start ${lib.escapeShellArg service} || echo "Failed to start ${service}"
        fi
      '') cfg.services}
    '';

  mkUserCheckScript = pkgs.writeShellScript "service-watchdog-user" ''
    ${lib.concatMapStringsSep "\n" (service: ''
      if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet ${lib.escapeShellArg service}; then
        echo "User service ${service} is not active, starting it..."
        ${pkgs.systemd}/bin/systemctl --user start ${lib.escapeShellArg service} || echo "Failed to start ${service}"
      fi
    '') cfg.userServices}
  '';
in
{
  options.nixos = {
    system.serviceWatchdog = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable a periodic watchdog that starts services if they are not active.";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* *:0/5:00";
        example = "hourly";
        description = "OnCalendar expression for how often the watchdog runs.";
      };

      services = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "smbd" "docker-nextcloud" ];
        description = "System services to watch. Started when not active.";
      };

      userServices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "xmousepasteblock" ];
        description = "User services to watch. Started when not active.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = config.nixos.system.user.defaultuser.name;
        example = "user";
        description = "User whose user services should be watched.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.service-watchdog = lib.mkIf (cfg.services != [ ]) {
      description = "Watchdog which starts inactive services";
      path = with pkgs; [ systemd ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = mkCheckScript "service-watchdog" "${pkgs.systemd}/bin/systemctl";
      };
    };

    systemd.timers.service-watchdog = lib.mkIf (cfg.services != [ ]) {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };

    users.users."${cfg.user}".linger = lib.mkIf (cfg.userServices != [ ]) true;

    systemd.user.services.service-watchdog = lib.mkIf (cfg.userServices != [ ]) {
      description = "Watchdog which starts inactive user services";
      path = with pkgs; [ systemd ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = mkUserCheckScript;
      };
    };

    systemd.user.timers.service-watchdog = lib.mkIf (cfg.userServices != [ ]) {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
