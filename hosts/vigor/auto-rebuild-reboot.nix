{
  config,
  pkgs,
  ...
}:

let
  user = config.nixos.system.user.defaultuser.name;

  autoRebuildRebootScript = pkgs.writeShellScript "auto-rebuild-reboot" ''
    ${pkgs.su}/bin/su ${user} -c '${pkgs.git}/bin/git pull'
    ${config.system.build.nixos-rebuild}/bin/nixos-rebuild boot || true
    ${pkgs.systemd}/bin/systemctl reboot
  '';
in
{
  systemd.services.auto-rebuild-reboot = {
    description = "Git pull, nixos-rebuild boot and reboot";
    path = with pkgs; [
      su
      sudo
      git
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = autoRebuildRebootScript;
      WorkingDirectory = "/home/${user}/nixos-config";
    };
  };

  systemd.timers.auto-rebuild-reboot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Wed *-*-* 04:00:00";
      Persistent = true;
    };
  };
}
