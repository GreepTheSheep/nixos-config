{ lib, ... }:

{
  programs.plasma = {
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
                "applications:code.desktop"
                #"applications:code-url-handler.desktop"
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
        ];
      }
      {
        location = "top";
        height = 26;
        widgets = [
          {
            iconTasks = {
              launchers = [];
              appearance ={
                rows.maximum = 5;
                iconSpacing = "medium";
              };
              behavior = {
                sortingMethod = "byHorizontalPosition";
                minimizeActiveTaskOnClick = true;
                middleClickAction = "newInstance";
                wheel = {
                  switchBetweenTasks = true;
                  ignoreMinimizedTasks = false;
                };
                showTasks = {
                  onlyInCurrentScreen = true;
                  onlyInCurrentDesktop = false;
                  onlyInCurrentActivity = true;
                  onlyMinimized = false;
                };
                newTasksAppearOn = "right";
              };
            };
          }
          {
            applicationTitleBar = {
              behavior = {
                activeTaskSource = "activeTask";
                filterByActivity = true;
                filterByScreen = true;
                filterByVirtualDesktop = true;
                disableForNotMaximized = false;
                disableButtonsForNotHovered = false;
              };
              layout = {
                elements = [ "windowTitle" ];
                horizontalAlignment = "left";
                showDisabledElements = "deactivated";
                verticalAlignment = "center";
              };
              overrideForMaximized.enable = false;
              titleReplacements = [
                {
                  type = "regexp";
                  originalTitle = ''\bDolphin\b'';
                  newTitle = "File manager";
                }
                {
                  type = "regexp";
                  originalTitle = ''\bVisual Studio Code.*\b'';
                  newTitle = "Visual Studio Code";
                }
                {
                  type = "regexp";
                  originalTitle = ''\bAntigravity.*\b'';
                  newTitle = "Antigravity";
                }
              ];
              windowTitle = {
                undefinedWindowTitle = "";
                font = {
                  bold = false;
                  fit = "fixedSize";
                  size = 10;
                };
                hideEmptyTitle = true;
                margins = {
                  bottom = 0;
                  left = 10;
                  right = 5;
                  top = 0;
                };
                source = "appName";
              };
            };
          }
          "org.kde.plasma.panelspacer"
          {
            plasmusicToolbar = {
              panelIcon = {
                albumCover = {
                  useAsIcon = true;
                  fallbackToIcon = true;
                  radius = 8;
                };
                icon = "view-media-track";
              };
              playbackSource = "auto";
              musicControls = {
                showPlaybackControls = true;
                volumeStep = 5;
              };
              songText = {
                displayInSeparateLines = true;
                maximumWidth = 400;
                scrolling = {
                  behavior = "alwaysScroll";
                  speed = 3;
                  resetOnPause = true;
                };
              };
              settings = {
                General = {
                  colorsFromAlbumCover = true;
                  mediaProgressInPanel = true;
                  fullAlbumCoverAsBackgrourd = true;
                  panelIconSizeRatio = 1;
                };
              };
            };
          }
          "org.kde.plasma.panelspacer"
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
              time.showSeconds = "always";
              date = {
                enable = true;
                position = "besideTime";
                format = {
                  custom = "ddd d/M/yyyy •";
                };
              };
              font = null;
            };
          }
        ];
      }
    ];
  };
}
