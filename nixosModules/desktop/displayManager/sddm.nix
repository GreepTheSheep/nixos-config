{ config, lib, pkgs, ...}:

{
  options.nixos = {
    desktop.displayManager.sddm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable SDDM display manager.";
      };

      wallpaper = lib.mkOption {
        type = lib.types.path;
        default = ../../../wallpaper/nuzi.jpg;
        example = ../../../wallpaper/stolas.png;
        description = "Wallpaper in SDDM display manager.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.displayManager.sddm.enable (let
    background-package = pkgs.runCommand "background-image" {} ''
      cp ${config.nixos.desktop.displayManager.sddm.wallpaper} $out
    '';
  in {
    services.displayManager = {
      sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
        theme = "breeze";
        enableHidpi = false;
      };
      defaultSession = "${config.nixos.desktop.displayManager.defaultSession}";
    };

    # Enable KWallet PAM unlocking
    security.pam.services.sddm.enableKwallet = true;
    security.pam.services.login.enableKwallet = true;

    environment.systemPackages = with pkgs; [
      wayland-utils
      wlr-randr
      (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = "${background-package}"
      '')
    ];
  });
}
