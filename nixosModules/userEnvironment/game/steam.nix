{ config, lib, pkgs, inputs, ... }:

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
    nixpkgs.overlays = [ inputs.millennium.overlays.default ];
    programs.steam = {
      enable = true;
      package = lib.mkMerge [
        (lib.mkIf config.nixos.userEnvironment.game.vr.enable (pkgs.millennium-steam.override {
          extraProfile = ''
            # Fixes timezones on VRChat
            unset TZ
            # Allows Monado/WiVRn to be used
            export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
          '';
        }))
        (lib.mkIf (!config.nixos.userEnvironment.game.vr.enable) pkgs.millennium-steam)
      ];
      #extraCompatPackages = with pkgs; [
        #steam-play-none
        #proton-ge-bin
      #];
      protontricks.enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      #extest.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;
  };
}