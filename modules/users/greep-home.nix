{ pkgs, ... }:

{
  # Home Manager needs a state version
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Add user-specific packages here later
    neofetch
  ];

  imports = [
    ../home/hyprland.nix
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
