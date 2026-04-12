{ config, lib, ... }:

{
  options.nixos = {
    base.shell.sudo = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable sudo parameters.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.shell.sudo.enable {
    security.sudo.extraRules = [
      {
        users = [ "${config.nixos.system.user.defaultuser.name}" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
        ] ++ lib.optionals (config.nixos.system.nixosvm.enable) [
          {
            command = "/opt/nixos-sandbox/result/bin/run-${osConfig.networking.hostName}-vm";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}