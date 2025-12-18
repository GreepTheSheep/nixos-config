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
    };
  };
}
