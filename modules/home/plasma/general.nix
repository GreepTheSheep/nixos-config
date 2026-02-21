{ lib, pkgs, config, osConfig, ... }:

let
  isLaptop = osConfig.networking.hostName == "laptop-hp-matt";
in
{
  imports = [
    ./panels.nix
    ./shortcuts.nix
  ];

  # Most Plasma configuration is done system-wide in modules/desktop/plasma
  # However, we can add user-specific Plasma settings here if needed.

  # Example: KDE Connect (phone integration)
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Example: Theme specific packages meant for KDE
  home.packages = with pkgs; [
    papirus-icon-theme
    # libsForQt5.qt5.qtgraphicaleffects
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = lib.mkForce "org.kde.breezedark.desktop";
      iconTheme = lib.mkForce "Papirus-Dark";
      wallpaper = "${../../../wallpaper/stolas.png}";
    };

    kscreenlocker = {
      lockOnResume = true;
      timeout = 5;
      passwordRequired = true;
      passwordRequiredDelay = 30;
      lockOnStartup = false;
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;
        wallpaper = "${../../../wallpaper/stolas.png}";
        wallpaperPictureOfTheDay = null;
        wallpaperSlideShow = null;
        wallpaperPlainColor = null;
      };
    };

    powerdevil = {
      AC = {
        powerButtonAction = "lockScreen";
        whenLaptopLidClosed = "doNothing";
        dimDisplay = lib.mkIf isLaptop {
          enable = true;
          idleTimeout = 300;
        };
        turnOffDisplay = lib.mkMerge [
          (lib.mkIf isLaptop {
            idleTimeout = 900;
            idleTimeoutWhenLocked = "immediately";
          })
          (lib.mkIf (!isLaptop) {
            idleTimeout = "never";
          })
        ];
        autoSuspend = {
          action = "nothing";
        };
      };
      battery = {
        powerButtonAction = "hibernate";
        whenLaptopLidClosed = "doNothing";
        dimDisplay = lib.mkIf isLaptop {
          enable = true;
          idleTimeout = 60;
        };
        turnOffDisplay = lib.mkMerge [
          (lib.mkIf isLaptop {
            idleTimeout = 120;
            idleTimeoutWhenLocked = "immediately";
          })
          (lib.mkIf (!isLaptop) {
            idleTimeout = "never";
          })
        ];
        autoSuspend = lib.mkIf isLaptop {
          action = "sleep";
          idleTimeout = 300;
        };
        whenSleepingEnter = "standbyThenHibernate";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
        turnOffDisplay = {
          idleTimeout = 60;
          idleTimeoutWhenLocked = "immediately";
        };
        autoSuspend = {
          action = "hibernate";
          idleTimeout = 120;
        };
      };
    };

    configFile = {
      kdeglobals."General" = {
        "ColorScheme" = "BreezeDark";
        # Set default web browser to Junction
        "BrowserApplication" = "re.sonny.Junction.desktop";
      };
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc.Desktops.Number = {
        value = 1;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
    };
  };
}
