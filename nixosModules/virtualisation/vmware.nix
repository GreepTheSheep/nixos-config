{ config, lib, pkgs, ... }:

{
  options.nixos = {
    virtualisation.vmware = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable vmware virtualisation.";
      };
    };
  };

  config = lib.mkIf config.nixos.virtualisation.vmware.enable {
    virtualisation.vmware.host = {
      enable = true;
      package = pkgs.vmware-workstation;
    };

    boot.kernelModules = [ "vmmon" "vmnet" ];

    environment.systemPackages = with pkgs; [
      vmware-workstation
    ];

    # Permissions pour les utilisateurs
    users.users."${config.nixos.system.user.defaultuser.name}" = {
      extraGroups = [
        "vmware"
      ];
    };
  };
}