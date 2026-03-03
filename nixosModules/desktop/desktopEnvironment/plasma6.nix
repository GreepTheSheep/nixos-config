{ config, lib, pkgs, ... }:

let
  spectacleOverlay = self: super: {
    kdePackages = super.kdePackages // {
      spectacle = super.kdePackages.spectacle.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ super.makeWrapper ];
        postInstall = ''
          wrapProgram $out/bin/spectacle \
            --prefix PATH : ${
              super.tesseract5.override {
                enableLanguages = [
                  "eng"
                  "osd"
                  "fra"
                ];
              }
            }/bin \
            --set TESSDATA_PREFIX ${
              super.tesseract5.override {
                enableLanguages = [
                  "eng"
                  "osd"
                  "fra"
                ];
              }
            }/share/tessdata \
            --prefix LD_LIBRARY_PATH : ${
              super.tesseract5.override {
                enableLanguages = [
                  "eng"
                  "osd"
                  "fra"
                ];
              }
            }/lib
        '';
      });
    };
  };
in

{
  options.nixos = {
    desktop.desktopEnvironment.plasma6 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Plasma6 desktop environment.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.desktopEnvironment.plasma6.enable {
    nixpkgs.overlays = [ spectacleOverlay ];

    services.desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };

    qt = {
      enable = true;
      platformTheme = "kde";
    };

    programs = {
      kdeconnect.package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;

      kde-pim = {
        enable = true;
        merkuro = true;
      };
    };

    environment = {
      plasma6.excludePackages =
        with pkgs;
        with kdePackages;
        [
          elisa
          breeze
          breeze-icons
          breeze-gtk
          oxygen
          oxygen-icons
          oxygen-sounds
          plasma-workspace-wallpapers
          plasma-welcome
          kmahjongg
          kmines
          konversation
          kpat
          ksudoku
          ktorrent
        ];

      systemPackages = (
        with pkgs;
        [
          kdiff3
        ]
      ) ++ (
        with pkgs;
        with kdePackages;
        [
          kaccounts-providers
          kaccounts-integration
          plasma-browser-integration
          plasma-pa
          plasma-nm
          plasma-disks
          plasma5support
          plasma-desktop
          plasma-activities
          plasma-thunderbolt
          plasma-integration
          plasma-systemmonitor
          plasma-activities-stats
          plasma-wayland-protocols
          print-manager
          libplasma
          systemsettings
          powerdevil
          kpipewire
          konsole
          bluedevil
          kdeplasma-addons
          kaccounts-integration
          akonadi
          akonadi-calendar-tools
          filelight
          maliit-keyboard
          libksysguard
          kate
          colord-kde
          spectacle
          kdepim-addons
          kcalc
          korganizer
          kcharselect
          kcolorchooser
          ksystemlog
          isoimagewriter
          kwallet-pam
          sddm-kcm
          #wallpaper-engine-plugin
          #linux-wallpaperengine
        ]
      );
    };
  };
}