{ pkgs, ... }:

{
  services = {
    # Display Management (SDDM)
    # SDDM is often used with KDE. If you use Hyprland only, you might still want a login manager.
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

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

  # Additional KDE Applications
  environment.systemPackages = with pkgs; [
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.ksystemlog
    kdePackages.sddm-kcm
    kdiff3
    kdePackages.isoimagewriter
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
