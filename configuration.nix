{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Desktop Environments
    ./modules/desktop/kde.nix
    ./modules/desktop/hyprland.nix # Optional: Comment out if you don't want Hyprland

    # Users
    ./modules/users/greep.nix

    # Applications
    ./modules/apps.nix
  ];

  system.stateVersion = "26.05";

  # ==========================================
  # Bootloader & Kernels
  # ==========================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==========================================
  # Networking & Locale
  # ==========================================
  networking.hostName = "nixos-custom";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  # ==========================================
  # Graphics & VM Support
  # ==========================================
  virtualisation = {
    vmware.guest.enable = true;
    virtualbox.guest.enable = lib.mkForce true;
  };
  services.xserver.videoDrivers = [ "modesetting" "vmware" "virtualbox" ];

  # ==========================================
  # Sound
  # ==========================================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==========================================
  # Nix Settings
  # ==========================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
