{ ... }:

{
  imports = [
    # Desktop Environments
    ./modules/desktop/sddm.nix
    ./modules/desktop/plasma.nix
    #./modules/desktop/hyprland.nix # Optional: Comment out if you don't want Hyprland

    # Users
    ./modules/users/greep.nix

    # Applications
    ./modules/apps.nix
    ./modules/fonts.nix

    # Networking
    ./modules/network/firewall.nix
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

    avahi.enable = true;

    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # RAOP
      raopOpenFirewall = true;
      extraConfig.pipewire = {
        # AirPlay
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";

              # increase the buffer size if you get dropouts/glitches
              # args = {
              #   "raop.latency.ms" = 500;
              # };
            }
          ];
        };

        # Low latency
        "92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 32;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 32;
          };
          "pulse.properties" = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "32/48000";
            "pulse.max.req" = "32/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "32/48000";
          };
          "stream.properties" = {
            "node.latency" = "32/48000";
            "resample.quality" = 1;
          };
        };
      };
    };

    # Bluetooth manager GUI (disabled as managed by DE)
    #blueman.enable = true;
  };

  security.rtkit.enable = true;

  # Nix Experimental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # XDG Portal integration
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  # Automatic delete of old generations
  #nix.gc.automatic = true;
  #nix.gc.dates = "weekly";
}
