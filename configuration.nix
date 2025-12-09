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

  # ==========================================
  # Bootloader & Kernels
  # ==========================================
  # Bootloader config is handled by the ISO build or the installer for the target system.
  # We disable it here to avoid conflicts with the live media boot process.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;

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
