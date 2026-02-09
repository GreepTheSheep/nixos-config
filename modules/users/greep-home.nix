{ pkgs, ... }:

{
  # Home Manager needs a state version
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Add user-specific packages here later
    neofetch
  ];

  systemd.user.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "code";
    XDG_DATA_DIRS = "${pkgs.xdg-utils}/share:/run/current-system/sw/share";
  };

  imports = [
    ../home/xdg.nix
    ../home/plasma/general.nix
    #../home/hyprland.nix
    ../home/flatpak.nix
    ../home/apps.nix
  ];

  # Media buttons on bluetooth devices
  services.mpris-proxy.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
