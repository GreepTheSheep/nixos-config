{ pkgs, ... }:

{
  # Home Manager needs a state version
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Add user-specific packages here later
    neofetch
    gearlever
  ];

  imports = [
    ../home/xdg.nix
    ../home/plasma.nix
    ../home/hyprland.nix
    ../home/zsh/zsh.nix
    ../home/gpg.nix
    ../home/git.nix
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
