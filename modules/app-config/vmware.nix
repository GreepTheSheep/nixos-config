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

  # Démarrer les services VMware
  systemd.services.vmware = {
    description = "VMware Workstation Server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.vmware-workstation}/bin/vmware-networks --start";
      ExecStop = "${pkgs.vmware-workstation}/bin/vmware-networks --stop";
    };
  };

  # Permissions pour les utilisateurs
  users.extraGroups.vmware = {};
  users.users.greep.extraGroups = [ "vmware" ];
}