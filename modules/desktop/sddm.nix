{ pkgs, ... }:

let
  background-package = pkgs.runCommand "background-image" {} ''
  cp ${../../wallpaper/stolas.png} $out
'';

in {
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "breeze";
        autoNumlock = true;
      };
    };
  };

  # Enable KWallet PAM unlocking
  security.pam.services.sddm.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;

  environment.systemPackages = with pkgs; [
    (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background = "${background-package}"
    '')
  ];
}