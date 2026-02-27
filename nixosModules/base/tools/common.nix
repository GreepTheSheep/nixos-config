{ config, lib, pkgs, ... }:

{
  options.nixos = {
    base.tools.common = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable common tools.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.common.enable {
    environment.systemPackages = with pkgs; [
      # fetchers
      fastfetch
      cpufetch

      # terminal file manager
      ranger

      # archives
      cdrkit
      p7zip
      unrar
      unzip
      xz
      zip
      zstd

      # utils
      progress
      parted
      gparted
      wget
      curl
      perl
      btop
      ncdu
      jq
      usbutils
      wl-clipboard
      imagemagick
      yt-dlp
      ffmpeg
      flac
      hardinfo2
      wayland-utils

      # networking tools
      inetutils
      ipfetch
      iftop
      nmap
      ipcalc

      # system call monitoring
      lsof # list open files
      ltrace # library call monitoring
      strace # system call monitoring

      # nix parsers and docs
      nixfmt
      nil
      nixd
      nixdoc
    ];
  };
}