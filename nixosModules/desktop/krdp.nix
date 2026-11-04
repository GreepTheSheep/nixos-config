{ config, lib, pkgs, ... }:

{
  options.nixos = {
    desktop.krdp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable the KRdp RDP server for Plasma Wayland sessions.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open the RDP port (TCP 3389) in the firewall.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.krdp.enable {
    environment.systemPackages = [
      pkgs.kdePackages.krdp
    ];

    nixos.system.firewall.extraAllowedTCPPorts =
      lib.optionals config.nixos.desktop.krdp.openFirewall [ 3389 ];
  };
}
