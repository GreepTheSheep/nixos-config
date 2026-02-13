{ pkgs, lib, config, ... }:

let
  hostname = config.networking.hostName;
in
{
  imports = [
    ./app-config/restic_backrest.nix
    ./app-config/steam.nix
    ./app-config/dev-tools.nix
    ./app-config/docker.nix
    ./app-config/zsh.nix
    ./app-config/spotify.nix
    #./app-config/virt-manager.nix
    ./app-config/vmware.nix
    ./app-config/helium-policies.nix

    # Non-nix apps are installed in /opt
    ./app-config/non-nix-apps/helium.nix
    ./app-config/non-nix-apps/feishin.nix
  ];

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core
    git
    vim
    wget
    curl
    perl
    zip
    unzip
    xdg-utils
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
    ncdu
    mission-center
    wayland-utils
    hardinfo2
    wl-clipboard
    imagemagick
    yt-dlp
    ffmpeg
    flac
  ];

  environment.defaultPackages = with pkgs; [
    # Requested Apps
    vscode
    antigravity
    vlc
    bitwarden-desktop
    jellyfin-media-player
    feishin
    junction
  ] ++ lib.optionals (hostname != "laptop-hp-matt") [
    # Those apps will not be installed on the laptop
    davinci-resolve
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
