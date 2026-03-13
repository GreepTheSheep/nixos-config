{ config, lib, pkgs, osConfig, ... }:

{
  options.homeManager = {
    applications.sync.deskflow = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable deskflow sync.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.sync.deskflow.enable {
    home.packages = with pkgs; [
      deskflow
    ];

    osConfig.nixos.system.firewall.extraAllowedTCPPorts = [ 24800 ];
    osConfig.nixos.system.firewall.extraAllowedUDPPorts = [ 24800 ];
  };
}