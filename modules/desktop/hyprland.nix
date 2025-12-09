{ pkgs, ... }:

{
  # ==========================================
  # Hyprland
  # ==========================================
  programs.hyprland.enable = true;

  # Optional: Helpful packages for a Hyprland session
  environment.systemPackages = with pkgs; [
    waybar       # Status bar
    rofi         # App launcher (rofi-wayland merged into rofi)
    dunst        # Notification daemon
    kitty        # Terminal
    hyprpaper    # Wallpaper
  ];
}
