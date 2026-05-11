{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.game.osu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable osu-lazer.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.game.osu.enable {
    environment.defaultPackages = with pkgs; [
      osu-lazer-bin
    ];
  };
}