{ config, lib, pkgs, ...}:

let
  background-package = pkgs.runCommand "background-image" {} ''
  cp ${../../../wallpaper/stolas.png} $out
'';
in
{
  options.nixos = {
    desktop.displayManager.sddm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable SDDM display manager.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.displayManager.sddm.enable {
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
  };
}