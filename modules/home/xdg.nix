{ pkgs, ... }:

{
  xdg = {
    portal = {
      enable = true;
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
        "text/html" = "junction.desktop";
        "application/xhtml+xml" = "junction.desktop";
        "x-scheme-handler/http" = "junction.desktop";
        "x-scheme-handler/https" = "junction.desktop";
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
        comment = "Code Editing. Redefined.";
        genericName = "Text Editor";
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

      # Junction
      junction = {
        name = "Junction";
        comment = "Browser Selector";
        genericName = "Browser Selector";
        exec = "${pkgs.junction}/bin/junction %U";
        icon = "junction";
        startupNotify = true;
        categories = [ "Network" "WebBrowser" ];
        mimeType = [ "text/html" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
        settings = {
          StartupWMClass = "Junction";
          Keywords = "junction";
        };
      };

      # Firefox
      firefox = {
        name = "Firefox";
        comment = "Firefox";
        genericName = "Web Browser";
        exec = "${pkgs.firefox}/bin/firefox %u";
        icon = "firefox";
        startupNotify = true;
        categories = [ "Network" "WebBrowser" ];
        mimeType = [ "text/html" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
        settings = {
          StartupWMClass = "Firefox";
          Keywords = "firefox";
        };
      };
    };
  };
}
