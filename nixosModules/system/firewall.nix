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

      extraAllowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        example = [
          80
          443
        ];
        description = "A list of extra allowed TCP ports.";
      };

      extraAllowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        example = [
          7777
        ];
        description = "A list of extra allowed UDP ports.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.firewall.enable {
    networking.firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
      ] ++ config.nixos.system.firewall.extraAllowedTCPPorts;

      allowedUDPPorts = [
        9 # Wake-on-LAN
      ] ++ config.nixos.system.firewall.extraAllowedUDPPorts;
    };
  };
}