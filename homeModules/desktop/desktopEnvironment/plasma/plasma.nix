{ lib, pkgs, config, osConfig, ... }:

let
  isLaptop = osConfig.host.isLaptop == true;
in
{
  options.homeManager = {
    desktop.desktopEnvironment.plasma.plasma-default = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable plasma default configs.";
      };
    };
  };

  config = lib.mkIf config.homeManager.desktop.desktopEnvironment.plasma.plasma-default.enable {

    # Example: KDE Connect (phone integration)
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    # Example: Theme specific packages meant for KDE
    home.packages = (
      with pkgs;
      [
        papirus-icon-theme
        # libsForQt5.qt5.qtgraphicaleffects
      ]
    ) ++ (
      with pkgs;
      with kdePackages;
      [
        libksysguard
        maliit-keyboard
        partitionmanager
      ]
    );

    programs.plasma = {
      enable = true;

      workspace = {
        lookAndFeel = lib.mkForce "org.kde.breezedark.desktop";
        iconTheme = lib.mkForce "Papirus-Dark";
        wallpaper = lib.mkForce "${../../../../wallpaper/stolas.png}";
      };

      kscreenlocker = {
        lockOnResume = true;
        timeout = lib.mkMerge [
            (lib.mkIf isLaptop 5)
            (lib.mkIf (!isLaptop) 15)
          ];
        passwordRequired = true;
        passwordRequiredDelay = 30;
        lockOnStartup = false;
        appearance = {
          alwaysShowClock = true;
          showMediaControls = true;
          wallpaper = lib.mkForce "${../../../../wallpaper/stolas.png}";
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
        kdeglobals.General = {
          ColorScheme = "BreezeDark";

          # Set default web browser to Junction
          BrowserApplication = "re.sonny.Junction.desktop";
        };

        baloofilerc."Basic Settings"."Indexing-Enabled" = false;

        kwinrc.Desktops.Number = {
          value = 1;
          # Forces kde to not change this value (even through the settings app).
          immutable = true;
        };

        klipperrc.General = {
          SyncClipboards = false; # Disable sync between X11 and Wayland clipboards
        };
      };
    };
  };
}
