{ config, lib, ... }:

{
  options.nixos = {
    system.firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable network firewall.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.firewall.enable {
    networking.firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22
        24800
      ];

      allowedUDPPorts = [
        24800
      ];
    };
  };
}