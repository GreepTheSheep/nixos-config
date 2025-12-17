{ ... }:

{
  imports = [
    # Desktop Environments
    ./modules/desktop/sddm.nix
    ./modules/desktop/plasma.nix
    ./modules/desktop/hyprland.nix # Optional: Comment out if you don't want Hyprland

    # Users
    ./modules/users/greep.nix

    # Applications
    ./modules/apps.nix
    ./modules/fonts.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking & Locale
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set your default locale.
  i18n.defaultLocale = "fr_FR.UTF-8";

  # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Bluetooth
  hardware.bluetooth.enable = true;

  services = {
    xserver = {
      # Configure keymap in X11
      xkb = {
        layout = "fr";
        variant = "";
      };

      # Graphics
      videoDrivers = [ "modesetting" ];
    };

    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # BLuetooth manager
    blueman.enable = true;
  };

  security.rtkit.enable = true;

  # Nix Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic delete of old generations
  #nix.gc.automatic = true;
  #nix.gc.dates = "weekly";
}
