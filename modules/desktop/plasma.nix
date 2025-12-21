{ pkgs, ... }:

{
  services = {
    # KDE Plasma 6 (Wayland)
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };

    # XRDP for remote desktop access
    xrdp = {
      defaultWindowManager = "startplasma-x11";
      enable = true;
      openFirewall = true;
    };

    # XServer is often required for the display manager service to spin up correctly
    xserver = {
      enable = true;

      xkb = {
        layout = "fr";
        variant = "";
      };
    };
  };

  programs.kdeconnect.enable = true; # Also ensures D-Bus setup

  # Additional KDE Applications
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.ksystemlog
    kdePackages.sddm-kcm
    kdiff3
    kdePackages.isoimagewriter
    kdePackages.kwallet-pam
  ];

  # Excludes some KDE applications
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.kdepim-runtime
    kdePackages.kmahjongg
    kdePackages.kmines
    kdePackages.konversation
    kdePackages.kpat
    kdePackages.ksudoku
    kdePackages.ktorrent
  ];
}
