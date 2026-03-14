{ config, lib, ... }:

{
  options.nixos = {
    userEnvironment.game.steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable steam.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.game.steam.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      extest.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;
  };
}