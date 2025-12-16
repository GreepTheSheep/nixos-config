{ pkgs, ... }:

{
  imports = [
    ./app-config/firefox.nix
    ./app-config/direnv.nix
    ./app-config/ohMyZsh.nix
  ];

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core
    git
    vim
    wget
    curl
    nixfmt
    nil
    nixd
    nixdoc

    # Fonts
    powerline-fonts
    meslo-lgs-nf
    nerd-fonts.zed-mono

    # Requested Apps
    vscode
    antigravity
    vlc
    zsh-powerlevel10k

    # Utilities
    gparted
    htop
    btop
    mission-center
    wayland-utils
    hardinfo2
    wl-clipboard
  ];

  # Flatpak
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
