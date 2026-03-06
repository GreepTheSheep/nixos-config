{ config, lib, pkgs, ...}:

{
  options.nixos = {
    desktop.xrdp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable xrdp settings.";
      };

      windowManager = lib.mkOption {
        type = lib.types.str;
        default = "startplasma-x11";
        example = "startplasma-x11";
        description = "The window manager to use for xrdp sessions.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.xrdp.enable {
    services.xrdp = {
      enable = true;
      defaultWindowManager = config.nixos.desktop.xrdp.windowManager;
      openFirewall = true;
    };
  };
}