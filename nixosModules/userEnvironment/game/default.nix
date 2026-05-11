{ config, lib, ... }:

{
  imports = [
    ./gamemode.nix
    ./gamescope.nix
    ./osu.nix
    ./steam.nix
    ./vr.nix
  ];

  options.nixos = {
    userEnvironment.game = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable game modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.game.enable {
    nixos.userEnvironment.game = {
      gamemode.enable = true;
      gamescope.enable = true;
      osu.enable = lib.mkDefault false;
      steam.enable = true;
      vr.enable = lib.mkDefault false;
    };
  };
}