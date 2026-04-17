{ config, lib, pkgs, ... }:

{
  options.nixos = {
    base.tools.at = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable at.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.at.enable {
    services.atd = {
      enable = true;
      #allowEveryone = true;
    };

    environment.systemPackages = with pkgs; [
      at
    ];

    users.users."${config.nixos.system.user.defaultuser.name}" = {
      extraGroups = [ "at" ];
    };
  };
}