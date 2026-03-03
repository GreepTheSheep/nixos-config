{ lib, config, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  options.homeManager = {
    desktop.desktopEnvironment.plasma.shortcuts = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable plasma shortcuts configs.";
      };
    };
  };

  config = lib.mkIf config.homeManager.desktop.desktopEnvironment.plasma.shortcuts.enable {
    programs.plasma = {
      shortcuts = {
        kmix = {
          "decrease_microphone_volume" = "Microphone Volume Down";
          "decrease_volume" = ["Meta+Shift+Down" "Volume Down"];
          "decrease_volume_small" = "Shift+Volume Down";
          "increase_microphone_volume" = "Microphone Volume Up";
          "increase_volume" = ["Volume Up" "Meta+Shift+Up"];
          "increase_volume_small" = "Shift+Volume Up";
          "mic_mute" = ["Microphone Mute" "Meta+Volume Mute"];
          "mute" = "Volume Mute";
        };

        ksmserver = {
          "Lock Session" = [ "Meta+L" "Screensaver" ];
          "Log Out" = "Ctrl+Alt+Del";
        };

        kwin = {
          # Window Management (KWin)
          "Activate Window Demanding Attention" = "Meta+Ctrl+A";
          "Edit Tiles" = "Meta+T";
          "Expose" = "Ctrl+F9";
          "ExposeAll" = ["Ctrl+F10" "Launch (C)"];
          "ExposeClass" = "Ctrl+F7";
          "Grid View" = "Meta+G";
          "Kill Window" = "Meta+Ctrl+Esc";
          "MoveMouseToCenter" = "Meta+F6";
          "MoveMouseToFocus" = "Meta+F5";
          "Overview" = "Meta+W";

          # Desktop Navigation
          "Switch One Desktop Down" = "Meta+Ctrl+Down";
          "Switch One Desktop Up" = "Meta+Ctrl+Up";
          "Switch One Desktop to the Left" = ["Ctrl+Alt+Left" "Meta+Left"];
          "Switch One Desktop to the Right" = ["Meta+Ctrl+Right" "Meta+Right" "Ctrl+Alt+Right"];

          # Window Navigation
          "Switch Window Down" = "Meta+Alt+Down";
          "Switch Window Left" = "Meta+Alt+Left";
          "Switch Window Right" = "Meta+Alt+Right";
          "Switch Window Up" = "Meta+Alt+Up";

          # Desktop Switching
          "Switch to Desktop 1" = "Ctrl+F1";
          "Switch to Desktop 2" = "Ctrl+F2";
          "Switch to Desktop 3" = "Ctrl+F3";
          "Switch to Desktop 4" = "Ctrl+F4";

          # Window Switching
          "Walk Through Windows" = ["Alt+Tab" "Meta+Tab"];
          "Walk Through Windows (Reverse)" = ["Alt+Shift+Tab" "Meta+Shift+Tab"];
          "Walk Through Windows of Current Application" = ["Alt+`" "Meta+`"];
          "Walk Through Windows of Current Application (Reverse)" = ["Alt+~" "Meta+~"];

          # Window Actions
          "Window Close" = ["Meta+Backspace" "Alt+F4"];
          "Window Maximize" = "Meta+PgUp";
          "Window Minimize" = ["Meta+H" "Meta+PgDown"];
          "Window Operations Menu" = "Alt+F3";

          # Window Movement Between Desktops
          "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
          "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
          "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
          "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";

          # Window Quick Tiling
          "Window Quick Tile Bottom" = "Meta+Down";
          "Window Quick Tile Left" = "Meta+Left";
          "Window Quick Tile Right" = "Meta+Right";
          "Window Quick Tile Top" = "Meta+Up";

          # Window Movement Between Screens
          "Window to Next Desktop" = "Meta+Shift+Right";
          "Window to Previous Desktop" = "Meta+Shift+Left";

          # Zoom Controls
          "view_actual_size" = "Meta+0";
          "view_zoom_in" = ["Meta++" "Meta+="];
          "view_zoom_out" = "Meta+-";
        };

        # Media Controls
        mediacontrol = {
          "nextmedia" = "Media Next";
          "pausemedia" = "Media Pause";
          "playpausemedia" = "Media Play";
          "previousmedia" = "Media Previous";
          "stopmedia" = "Media Stop";
        };

        # Power Management
        "org_kde_powerdevil" = {
          "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
          "Decrease Screen Brightness" = "Monitor Brightness Down";
          "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
          "Hibernate" = "Hibernate";
          "Increase Keyboard Brightness" = "Keyboard Brightness Up";
          "Increase Screen Brightness" = "Monitor Brightness Up";
          "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
          "PowerDown" = "Power Down";
          "PowerOff" = "Power Off";
          "Sleep" = "Sleep";
          "Toggle Keyboard Backlight" = "Keyboard Light On/Off";
          "powerProfile" = "Battery";
        };

        # Plasma Shell
        plasmashell = {
          "activate application launcher" = ["Meta" "Alt+F1"];
          "activate task manager entry 1" = "Meta+&";
          "activate task manager entry 2" = "Meta+é";
          "activate task manager entry 3" = "Meta+\"";
          "activate task manager entry 4" = "Meta+'";
          "activate task manager entry 5" = "Meta+(";
          "activate task manager entry 6" = "Meta+-";
          "activate task manager entry 7" = "Meta+è";
          "activate task manager entry 8" = "Meta+_";
          "activate task manager entry 9" = "Meta+ç";

          # Clipboard
          "clipboard_action" = "Meta+Ctrl+X";
          "cycle-panels" = "Meta+Alt+P";
          "show-on-mouse-pos" = "Meta+V";

          # Activities
          "manage activities" = "Meta+Q";
          "next activity" = "Meta+A";
          "previous activity" = "Meta+Shift+A";
          "stop current activity" = "Meta+S";
          "show dashboard" = "Ctrl+F12";
        };
      };
    };
  };
}