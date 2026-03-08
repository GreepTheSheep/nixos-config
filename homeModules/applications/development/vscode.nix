{ config, lib, pkgs, ... }:

let
  vsCodeSettings = builtins.toJSON {
    "telemetry.enableTelemetry" = false;
    "telemetry.enableCrashReporter" = false;
    "telemetry.telemetryLevel" = "off";
    "files.autoSave" = "off";
    "window.title" = "\${dirty}\${activeEditorShort}\${separator}\${rootName}\${separator}\${appName}\${separator}\${remoteName}";
    "window.titleSeparator" = " ➖ ";
    "window.newWindowDimensions" = "maximized";
    "extensions.ignoreRecommendations" = true;
    "editor.tabSize" = 4;
    "[nix]"."editor.tabSize" = 2;
    "editor.defaultFormatter" ="vscode.json-language-features";
    "security.workspace.trust.untrustedFiles" = "open";
    "update.mode" = "none";
    "git.enableSmartCommit" = true;
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "discord.detailsEditing" = "{file_name}";
    "discord.detailsIdle" = "Doing absouluty nothing on it...";
    "discord.largeImageIdle" = "Cool keyboard :)";
    "discord.lowerDetailsEditing" = "{workspace} ({git_branch})";
    "discord.lowerDetailsIdle" = "Maybe Greep is sleping 💤";
    "discord.lowerDetailsDebugging" = "🕷 {workspace} ({git_branch})";
    "discord.detailsIdling" = "{empty}";
    "discord.lowerDetailsNoWorkspaceFound" = "{empty}";
    "editor.multiCursorModifier" = "ctrlCmd";
    "terminal.integrated.gpuAcceleration" = "off";
    "terminal.integrated.fontFamily" = "CaskaydiaCove Nerd Font";
    "window.confirmBeforeClose" = "never";
    "notebook.lineNumbers" = "on";
    "window.zoomLevel" = 0;
    "claudeCode.useCtrlEnterToSend" = true;

    "diffEditor.ignoreTrimWhitespace" = false;
    "files.trimTrailingWhitespace" = true;
    "editor.linkedEditing" = true;
    "editor.bracketPairColorization.enabled" = false;
    "window.commandCenter" = true;
    "editor.mouseWheelZoom" = true;

    "workbench.iconTheme" = "vscode-icons";
    "workbench.colorCustomizations" = {
      "activityBarBadge.background" = "#388E3C";
      "activityBar.activeBorder" = "#388E3C";
      "list.activeSelectionForeground" = "#388E3C";
      "list.inactiveSelectionForeground" = "#388E3C";
      "list.highlightForeground" = "#388E3C";
      "scrollbarSlider.activeBackground" = "#388E3C50";
      "editorSuggestWidget.highlightForeground" = "#388E3C";
      "textLink.foreground" = "#388E3C";
      "progressBar.background" = "#388E3C";
      "pickerGroup.foreground" = "#388E3C";
      "tab.activeBorder" = "#388E3C";
      "notificationLink.foreground" = "#388E3C";
      "editorWidget.resizeBorder" = "#388E3C";
      "editorWidget.border" = "#388E3C";
      "settings.modifiedItemIndicator" = "#388E3C";
      "settings.headerForeground" = "#388E3C";
      "panelTitle.activeBorder" = "#388E3C";
      "breadcrumb.activeSelectionForeground" = "#388E3C";
      "menu.selectionForeground" = "#388E3C";
      "menubar.selectionForeground" = "#388E3C";
      "editor.findMatchBorder" = "#388E3C";
      "selection.background" = "#388E3C40";
      "statusBarItem.remoteBackground" = "#388E3C";
      "[Material Theme Darker High Contrast]" = {
        "activityBarBadge.background" = "#616161";
        "activityBar.activeBorder" = "#616161";
        "list.activeSelectionForeground" = "#616161";
        "list.inactiveSelectionForeground" = "#616161";
        "list.highlightForeground" = "#616161";
        "scrollbarSlider.activeBackground" = "#61616150";
        "editorSuggestWidget.highlightForeground" = "#616161";
        "textLink.foreground" = "#616161";
        "progressBar.background" = "#616161";
        "pickerGroup.foreground" = "#616161";
        "tab.activeBorder" = "#616161";
        "notificationLink.foreground" = "#616161";
        "editorWidget.resizeBorder" = "#616161";
        "editorWidget.border" = "#616161";
        "settings.modifiedItemIndicator" = "#616161";
        "settings.headerForeground" = "#616161";
        "panelTitle.activeBorder" = "#616161";
        "breadcrumb.activeSelectionForeground" = "#616161";
        "menu.selectionForeground" = "#616161";
        "menubar.selectionForeground" = "#616161";
        "editor.findMatchBorder" = "#616161";
        "selection.background" = "#61616140";
        "statusBarItem.remoteBackground" = "#616161";
      };
    };
  };
in
{
  options.homeManager = {
    applications.development.vscode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Visual Studio Code.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = true;

        extensions = with pkgs.vscode-extensions; [
          ms-ceintl.vscode-language-pack-fr
          shardulm94.trailing-spaces
          ms-vscode.test-adapter-converter
          hbenl.vscode-test-explorer
          vscode-icons-team.vscode-icons
          esbenp.prettier-vscode
          bbenoist.nix
          jnoortheen.nix-ide
          usernamehw.errorlens
          editorconfig.editorconfig
          ms-azuretools.vscode-docker
          ritwickdey.liveserver
          ms-vscode-remote.remote-containers
          anthropic.claude-code
        ];

        keybindings = [
          {
            "key" = "ctrl+k ctrl+shift+b";
            "command" = "workbench.action.tasks.test";
          }
          {
            "key" = "ctrl+k ctrl+shift+t";
            "command" = "workbench.action.terminal.new";
          }
          {
            "key" = "ctrl+shift+t";
            "command" = "workbench.action.reopenClosedEditor";
          }
          {
            "key" = "ctrl+shift+n";
            "command" = "workbench.action.files.newUntitledFile";
          }
          {
            "key" = "ctrl+shift+w";
            "command" = "workbench.action.closeAllEditors";
          }
          {
            "key" = "ctrl+shift+s";
            "command" = "workbench.action.files.saveAll";
          }
        ];
      };
    };

    home.file.".config/Code/User/settings.json".text = vsCodeSettings;
  };
}