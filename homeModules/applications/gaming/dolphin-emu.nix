{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.gaming.dolphin-emu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Dolphin Emulator.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.dolphin-emu.enable {
    home.packages = with pkgs; [
      dolphin-emu
    ];
  };
}
