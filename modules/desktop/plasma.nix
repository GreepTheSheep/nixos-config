{ pkgs, lib, config, ... }:

let
  hostname = config.networking.hostName;
in
{
  imports = [
    ../app-config/pkgs/wallpaper-engine-kde-plugin.nix
  ];

  services = {
    # KDE Plasma 6 (Wayland)
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };

    # XRDP for remote desktop access
    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-x11";
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

  programs = {
    kdeconnect.enable = true; # Also ensures D-Bus setup

    kde-pim = {
      enable = true;
      merkuro = true;
    };
  };

  # Additional KDE Applications
  environment.systemPackages = with pkgs; [
    kdePackages.kdepim-runtime
    kdePackages.kdepim-addons
    kdePackages.korganizer
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.ksystemlog
    kdePackages.sddm-kcm
    kdiff3
    kdePackages.isoimagewriter
    kdePackages.kwallet-pam
    kdePackages.krdp
  ];

  # Excludes some KDE applications
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.kmahjongg
    kdePackages.kmines
    kdePackages.konversation
    kdePackages.kpat
    kdePackages.ksudoku
    kdePackages.ktorrent
  ];

  # Wallpaper Engine KDE plugin
  nixos.pkgs.wallpaper-engine-kde-plugin.enable = lib.mkIf (hostname != "laptop-hp-matt") true; # Don't enable on the laptop

}
