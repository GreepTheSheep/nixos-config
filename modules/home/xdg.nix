{ pkgs, ... }:

{
  xdg = {
    enable = true;
    portal = {
      enable = true;
      config.common.default = "*";
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/vscode" = "code.desktop";
        "x-scheme-handler/antigravity" = "antigravity.desktop";
        # Browser set to Junction (browser selector)
        "text/html" = "re.sonny.Junction.desktop";
        "application/xhtml+xml" = "re.sonny.Junction.desktop";
        "x-scheme-handler/http" = "re.sonny.Junction.desktop";
        "x-scheme-handler/https" = "re.sonny.Junction.desktop";
      };
    };

    desktopEntries = {
      code = {
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

      antigravity = {
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
      firefox = {
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
      helium = {
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
      feishin = {
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

    };
  };
}
