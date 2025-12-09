{ pkgs, ... }:

{
  # ==========================================
  # Common System Applications
  # ==========================================

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core
    git
    vim
    wget
    curl

    # Requested Apps
    firefox
    vscode
    vlc

    # Utilities
    gparted
    htop
  ];

  # ==========================================
  # Flatpak
  # ==========================================
  services.flatpak.enable = true;
}
