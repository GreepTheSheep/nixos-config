{ pkgs, ... }:

{
  imports = [
    ./app-config/steam.nix
    ./app-config/docker.nix
    ./app-config/zsh.nix
    ./app-config/spotify.nix
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
    zsh-powerlevel10k
    steam-devices-udev-rules # Udev rules for steam input devices

    # Utilities
    gparted
    htop
    btop
    mission-center
    wayland-utils
    hardinfo2
    wl-clipboard
  ];

  environment.defaultPackages = with pkgs; [
    # Requested Apps
    vscode
    antigravity
    vlc
    bitwarden-desktop
    jellyfin-media-player
  ];

  programs.direnv.enable = true;

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
