{ pkgs, ... }:

{
  imports = [
    ./app-config/firefox.nix
    ./app-config/direnv.nix
  ];

  # Flatpak
  services.flatpak.enable = true;

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core
    git
    vim
    wget
    curl

    # Requested Apps
    vscode
    vlc

    # Utilities
    gparted
    htop
  ];
}
