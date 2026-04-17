{ pkgs, ... }:

let
  user = config.nixos.system.user.defaultuser.name;

  autoRebuildRebootScript = pkgs.writeShellScript "auto-rebuild-reboot" ''
    ${pkgs.su}/bin/su ${user} -c '${pkgs.git}/bin/git -C /home/${user}/nixos-config pull'
    ${pkgs.nix}/bin/nixos-rebuild boot || true
    ${pkgs.systemd}/bin/systemctl reboot
  '';
in
{
  systemd.services.auto-rebuild-reboot = {
    description = "Git pull, nixos-rebuild boot and reboot";
    path = with pkgs; [ su git nix ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = autoRebuildRebootScript;
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