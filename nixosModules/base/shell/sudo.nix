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
        ];
      }
    ];
  };
}