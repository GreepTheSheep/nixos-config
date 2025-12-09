_:

{
  services = {
    # ==========================================
    # Display Management (SDDM)
    # ==========================================
    # SDDM is often used with KDE. If you use Hyprland only, you might still want a login manager.
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # ==========================================
    # KDE Plasma 6 (Wayland)
    # ==========================================
    desktopManager = {
      plasma6 = {
        enable = true;
      };
    };

    # XServer is often required for the display manager service to spin up correctly
    xserver = {
      enable = true;
    };
  };
}
