{ pkgs, ... }:

{
  # Most Plasma configuration is done system-wide in modules/desktop/kde.nix
  # However, we can add user-specific Plasma settings here if needed.

  # Example: KDE Connect (phone integration)
  # services.kdeconnect = {
  #   enable = true;
  #   indicator = true;
  # };

  # Example: Theme specific packages meant for KDE
  home.packages = with pkgs; [
    papirus-icon-theme
    # libsForQt5.qt5.qtgraphicaleffects
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
      wallpaper = "../../wallpaper/stolas.png";
    };
  };
}
