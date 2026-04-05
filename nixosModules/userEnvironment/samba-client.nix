{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.samba-client = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable samba client and command-line tools.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.samba-client.enable {
    services.gvfs.enable = true;
    environment.defaultPackages = with pkgs; [
      samba4Full
      samba
    ];
  };
}