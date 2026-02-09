{ pkgs, ... }:

{
  virtualisation.vmware.host = {
    enable = true;
    package = pkgs.vmware-workstation;
  };

  boot.kernelModules = [ "vmmon" "vmnet" ];

  environment.systemPackages = with pkgs; [
    vmware-workstation
  ];

  # Permissions pour les utilisateurs
  users.extraGroups.vmware = {};
  users.users.greep.extraGroups = [ "vmware" ];
}