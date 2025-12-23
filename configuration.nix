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
    ./modules/davfs.nix
    ./modules/apps.nix
    ./modules/fonts.nix

    # Networking
    ./modules/network/firewall.nix
  ];

  # Sops secrets
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    gnupg.home = "/home/greep/.gnupg";

    secrets = {
      "nextcloud/password" = {};
    };
  };

  hardware.enableAllFirmware = true;

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
      };

      wireplumber.extraConfig = {
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # Ne pas forcer les profils HSP/HFP - ils seront activés automatiquement
            # uniquement quand une application VoIP (Discord, etc.) utilise le microphone
            "bluez5.headset-roles" = [ "hfp_ag" "hsp_ag" ];
            # Profil par défaut : A2DP (haute qualité stéréo)
            "bluez5.auto-connect" = [ "a2dp_sink" ];
          };
        };

        # Basculement automatique intelligent entre A2DP et HSP/HFP
        "51-bluez-autoswitch" = {
          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  # S'applique à tous les périphériques Bluetooth
                  "device.name" = "~bluez_card.*";
                }
              ];
              actions = {
                update-props = {
                  # Profil par défaut : A2DP (audio haute qualité)
                  "bluez5.auto-connect" = [ "a2dp_sink" ];
                  # Bascule vers HFP uniquement si une source audio est requise (appel VoIP)
                  "bluez5.profile" = "auto";
                };
              };
            }
          ];
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
