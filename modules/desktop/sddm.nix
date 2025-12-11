{ pkgs, ... }:

let
  background-package = pkgs.runCommand "background-image" {} ''
  cp ${./wallpaper/stolas.png} $out
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

  environment.systemPackages = [
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background = "${background-package}"
    '')
  ];
}