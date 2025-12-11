{ pkgs, ... }:

{
  # Most Plasma configuration is done system-wide in modules/desktop/kde.nix
  # However, we can add user-specific Plasma settings here if needed.

  # Example: KDE Connect (phone integration)
  # services.kdeconnect = {
  #   enable = true;
  #   indicator = true;
  # };

  # Example: Theme specific packages meant for KDE
  home.packages = with pkgs; [
    papirus-icon-theme
    # libsForQt5.qt5.qtgraphicaleffects
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
      wallpaper = "/etc/nixos/wallpaper/stolas.png";
    };

    panels = [
      {
        location = "bottom";
        hiding = "windowsgobelow";
        widgets = [
          {
            kickoff = {
              icon = "nix-snowflake-white";
            };
          }
          {
            iconTasks = {
              launchers = [
                "applications:firefox.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:code.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.volume"
              ];
              # hidden = [];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
              time.showSeconds = "always";
            };
          }
          {
            systemMonitor = {
              sensors = [
                {
                  name = "cpu/all/usage";
                  color = "91,126,252";
                  label = "CPU %";
                }
                {
                  name = "mem/all/usage";
                  color = "91,126,252";
                  label = "Memory %";
                }
              ];
            };
          }
        ];
      }
    ];

    powerdevil = {
      AC = {
        powerButtonAction = "lockScreen";
        autoSuspend = {
          action = "shutDown";
          idleTimeout = 1000;
        };
        turnOffDisplay = {
          idleTimeout = 1000;
          idleTimeoutWhenLocked = "immediately";
        };
      };
      battery = {
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
      };
    };

    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+L"
        ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      };
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc.Desktops.Number = {
        value = 1;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
      kscreenlockerrc = {
        # Set wallpaper for lock screen
        Greeter = {
          WallpaperPlugin = "org.kde.image";
          Wallpaper = "/etc/nixos/wallpaper/stolas.png";
        };
      };
    };
  };
}
