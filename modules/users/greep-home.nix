{ pkgs, ... }:

{
  # Home Manager needs a state version
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Add user-specific packages here later
    neofetch
  ];

  imports = [
    ../home/xdg.nix
    ../home/plasma/general.nix
    ../home/hyprland.nix
    ../home/flatpak.nix
    ../home/programs/zsh/zsh.nix
    ../home/programs/gpg.nix
    ../home/programs/git.nix
    ../home/programs/rbw.nix
  ];

  # Media buttons on bluetooth devices
  services.mpris-proxy.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
