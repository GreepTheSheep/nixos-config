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
        hiding = "dodgewindows";
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
              displayStyle = "org.kde.ksysguard.piechart";

              textOnlySensors = [ "cpu/cpu.*/usage" "cpu/all/averageFrequency" "cpu/all/averageTemperature"];
              totalSensors = [ "cpu/all/usage"];

              sensors = [{
                name = "cpu/all/usage";
                color = "91,126,252";  # Bleu
                label = "CPU %";
              }];
              title = "Processeur";
              showTitle = true;
            };
          }
          {
            systemMonitor = {
              displayStyle = "org.kde.ksysguard.piechart";

              textOnlySensors = [ "memory/physical/total" ];
              totalSensors = [ "memory/physical/usedPercent" ];

              sensors = [{
                name = "memory/physical/used";
                color = "91,252,126";  # Vert
                label = "Mémoire";
              }];
              title = "Mémoire";
              showTitle = true;
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
