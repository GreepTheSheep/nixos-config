{ config, lib, pkgs, osConfig, ... }:

{
  options.homeManager = {
    desktop.xdg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable xdg settings.";
      };
    };
  };

  config = lib.mkIf config.homeManager.desktop.xdg.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";
      dataHome = config.home.homeDirectory + "/.local/share";
      configHome = config.home.homeDirectory + "/.config";
      stateHome = config.home.homeDirectory + "/.local/state";

      mimeApps = {
        enable = true;
        defaultApplications = osConfig.xdg.mime.defaultApplications;
        associations.added = osConfig.xdg.mime.addedAssociations;
      };

      #configFile."mimeapps.list".enable = false;
      #dataFile."applications/mimeapps.list".force = true;

      configFile."mimeapps.list" = lib.mkIf config.xdg.mimeApps.enable { force = true; };

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          SCREENSHOTS = "${config.xdg.userDirs.desktop}";
          GAMES = "${config.home.homeDirectory}/Games";
        };
      };

      desktopEntries = {
        code = lib.mkIf (config.homeManager.applications.development.vscode.enable) {
          name = "Visual Studio Code";
          comment = "Code Editing. Redefined.";
          genericName = "Text Editor";
          exec = "${pkgs.writeShellScript "code-wrapper" ''
            if echo "$1" | grep -q "^vscode:"; then
              code --open-url "$@"
            else
              code "$@"
            fi
          ''} %U";
          icon = "vscode";
          startupNotify = true;
          categories = [ "Utility" "TextEditor" "Development" "IDE" ];
          mimeType = [ "text/plain" "inode/directory" "x-scheme-handler/vscode" ];
          settings = {
            StartupWMClass = "Code";
            Keywords = "vscode";
          };
          actions = {
            new-empty-window = {
              name = "New Empty Window";
              exec = "code --new-window %F";
              icon = "vscode";
            };
          };
        };

        antigravity = lib.mkIf (config.homeManager.applications.development.antigravity.enable) {
          name = "Antigravity";
          comment = "Code Editing. AI-Powered.";
          genericName = "AI-Powered Text Editor";
          exec = "${pkgs.writeShellScript "antigravity-wrapper" ''
            if echo "$1" | grep -q "^antigravity:"; then
              antigravity --open-url "$@"
            else
              antigravity "$@"
            fi
          ''} %U";
          icon = "antigravity";
          startupNotify = true;
          categories = [ "Utility" "TextEditor" "Development" "IDE" ];
          mimeType = [ "text/plain" "inode/directory" "x-scheme-handler/antigravity" ];
          settings = {
            StartupWMClass = "Antigravity";
            Keywords = "vscode";
          };
          actions = {
            new-empty-window = {
              name = "New Empty Window";
              exec = "antigravity --new-window %F";
              icon = "antigravity";
            };
          };
        };

        # Firefox
        firefox = lib.mkIf (config.homeManager.applications.browser.firefox.enable) {
          name = "Firefox";
          comment = "Web Browser";
          genericName = "Web Browser";
          exec = "${pkgs.firefox}/bin/firefox %U";
          icon = "firefox";
          startupNotify = true;
          categories = [ "Network" "WebBrowser" ];
          mimeType = [ "application/pdf" "application/rdf+xml" "application/rss+xml" "application/xhtml+xml" "application/xhtml_xml" "application/xml" "image/gif" "image/jpeg" "image/png" "image/webp" "text/html" "text/xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
          settings = {
            StartupWMClass = "Firefox";
            Keywords = "firefox;web browser";
          };
          actions = {
            new-window = {
              name = "New Window";
              exec = "firefox %F";
            };
            new-private-window = {
              name = "New Private Window";
              exec = "firefox --private-window %F";
            };
          };
        };

        # Helium
        helium = lib.mkIf (osConfig.nixos.userEnvironment.non-nix-apps.helium.enable) {
          name = "Helium";
          comment = "Web Browser";
          genericName = "Web Browser";
          exec = "/opt/helium/helium %U";
          icon = "/opt/helium/product_logo_256.png";
          startupNotify = true;
          terminal = false;
          categories = [ "Network" "WebBrowser" ];
          mimeType = [ "application/pdf" "application/rdf+xml" "application/rss+xml" "application/xhtml+xml" "application/xhtml_xml" "application/xml" "image/gif" "image/jpeg" "image/png" "image/webp" "text/html" "text/xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
          settings = {
            Type = "Application";
            StartupWMClass = "helium";
            Keywords = "helium;web browser";
          };
          actions = {
            new-window = {
              name = "New Window";
              exec = "/opt/helium/helium %U";
            };
            new-private-window = {
              name = "New Incognito Window";
              exec = "/opt/helium/helium --incognito %U";
            };
          };
        };

        # Feishin
        feishin = lib.mkIf (osConfig.nixos.userEnvironment.non-nix-apps.feishin.enable)  {
          name = "Feishin";
          comment = "Un lecteur de musique moderne auto-hébergé.";
          genericName = "Lecteur de musique";
          exec = "/opt/feishin/feishin --no-sandbox --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto %U";
          icon = "/opt/feishin/resources/assets/icons/256x256.png";
          terminal = false;
          startupNotify = true;
          categories = [ "AudioVideo" "Audio" "Music" "Player" ];
          settings = {
            Keywords = "jellyfin;feishin;music player";
            TryExec = "/opt/feishin/feishin";
            StartupWMClass = "feishin";
            SingleMainWindow = "true";
          };
        };

        # Backrest (opens http://backrest:9898)
        backrest = lib.mkIf (osConfig.nixos.base.tools.backrest.enable) {
          name = "Backrest";
          comment = "Utilitaire de sauvegardes avec Restic.";
          genericName = "Backup utility";
          exec = "xdg-open http://backrest:9898/";
          terminal = false;
          startupNotify = false;
          categories = [ "Utility" "FileTools" ];
        };
      };
    };
  };
}