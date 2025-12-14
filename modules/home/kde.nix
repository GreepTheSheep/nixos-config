{ lib, pkgs, ... }:

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
      lookAndFeel = lib.mkForce "org.kde.breezedark.desktop";
      iconTheme = lib.mkForce "Papirus-Dark";
      wallpaper = "${../../wallpaper/stolas.png}";
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
        wallpaper = "${../../wallpaper/stolas.png}";
        wallpaperPictureOfTheDay = null;
        wallpaperSlideShow = null;
        wallpaperPlainColor = null;
      };
    };

    panels = [
      {
        location = "bottom";
        screen = "all";
        hiding = "dodgewindows";
        opacity = "translucent";
        floating = true;
        height = lib.mkForce 44;
        widgets = [
          {
            panelSpacer = {
              expanding = true;
            };
          }
          {
            kickoff = {
              icon = lib.mkForce "nix-snowflake-white";
              favoritesDisplayMode = "grid";
              applicationsDisplayMode = "list";
              showActionButtonCaptions = false;
              showButtonsFor = {
                custom = [
                  "shutdown"
                  "reboot"
                  "logout"
                ];
              };
            };
          }
          {
            iconTasks = {
              launchers = [
                "applications:firefox.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:code-url-handler.desktop"
              ];
            };
          }
          {
            panelSpacer = {
              expanding = true;
            };
          }
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
            name = "org.kde.plasma.systemmonitor";
            config = {
              Appearance = {
                title = "Processeur";
                chareFace = "org.kde.ksysguard.piechart";
                updateRateLimit = "1000";
              };
              SensorLabels = {
                "cpu/all/usage" = "Usage";
                "cpu/all/averageFrequency" = "Frequence moyenne";
                "cpu/all/averageTemperature" = "Temperature moyenne";
              };
              SensorColors = {
                "cpu/all/usage" = "14,0,209"; # Bleu
              };
              Sensors = {
                highPrioritySensorIds = ''["cpu/all/usage"]'';
                lowPrioritySensorIds = ''["cpu/cpu.*/usage","cpu/all/averageFrequency","cpu/all/averageTemperature"]'';
                totalSensors = ''["cpu/all/usage"]'';
              };
            };
          }
          {
            name = "org.kde.plasma.systemmonitor";
            config = {
              Appearance = {
                title = "Mémoire";
                chareFace = "org.kde.ksysguard.piechart";
                updateRateLimit = "1000";
              };
              SensorLabels = {
                "memory/physical/usedPercent" = "Usage %";
                "memory/physical/used" = "Utilisation";
                "memory/swap/used" = "Utilisation Swap";
                "memory/swap/usedPercent" = "Usage Swap %";
                "memory/physical/total" = "Total";
                "memory/swap/total" = "Total Swap";
              };
              SensorColors = {
                "memory/physical/usedPercent" = "0,209,14"; # Vert
                "memory/swap/usedPercent" = "171,80,0"; # Orange
              };
              Sensors = {
                highPrioritySensorIds = ''["memory/physical/usedPercent","memory/swap/usedPercent"]'';
                lowPrioritySensorIds = ''["memory/physical/used","memory/physical/total","memory/swap/used","memory/swap/total"]'';
                totalSensors = ''["memory/physical/usedPercent","memory/swap/usedPercent"]'';
              };
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
              time.showSeconds = "always";
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
        "Switch Window Down" = "Meta+Down";
        "Switch Window Left" = "Meta+Left";
        "Switch Window Right" = "Meta+Right";
        "Switch Window Up" = "Meta+Up";
      };
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc.Desktops.Number = {
        value = 1;
        # Forces kde to not change this value (even through the settings app).
        immutable = true;
      };
    };
  };
}
