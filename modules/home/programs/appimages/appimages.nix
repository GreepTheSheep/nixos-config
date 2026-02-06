{ config, lib, pkgs, ... }:

let
  cfg = config.appimages;
  appimagesDir = "${config.home.homeDirectory}/AppImages";
  iconsDir = "${config.home.homeDirectory}/.local/share/icons/appimages";

  # Génère le script de téléchargement et extraction d'icône pour une AppImage
  mkDownloadScript = name: appCfg: 
    let
      isGitHub = appCfg.githubRepo != "";
      # Pattern pour filtrer les assets (ex: "x86_64.AppImage")
      assetPattern = if appCfg.githubAssetPattern != "" then appCfg.githubAssetPattern else ".AppImage";
    in ''
    APPIMAGE_PATH="${appimagesDir}/${appCfg.filename}"
    ICON_NAME="${appCfg.desktopEntry.name}"
    
    # Déterminer l'URL de téléchargement
    ${if isGitHub then ''
      echo "Récupération de la dernière version de ${name} depuis GitHub..."
      DOWNLOAD_URL=$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/${appCfg.githubRepo}/releases/latest" | \
        ${pkgs.jq}/bin/jq -r '.assets[] | select(.name | contains("${assetPattern}")) | .browser_download_url' | head -1)
      
      if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
        echo "Erreur: Impossible de trouver l'URL de téléchargement pour ${name}"
        exit 1
      fi
      echo "URL trouvée: $DOWNLOAD_URL"
    '' else ''
      DOWNLOAD_URL="${appCfg.url}"
    ''}
    
    if [ -n "$DOWNLOAD_URL" ]; then
      if [ ! -f "$APPIMAGE_PATH" ] || [ "${if appCfg.autoUpdate then "1" else "0"}" = "1" ]; then
        echo "Téléchargement de ${name}..."
        ${pkgs.curl}/bin/curl -L -o "$APPIMAGE_PATH" "$DOWNLOAD_URL"
        chmod +x "$APPIMAGE_PATH"
        echo "${name} téléchargé avec succès!"
        
        # Extraction automatique de l'icône
        echo "Extraction de l'icône de ${name}..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Extraire tout le contenu de l'AppImage
        "$APPIMAGE_PATH" --appimage-extract 2>/dev/null || {
          echo "Erreur lors de l'extraction de l'AppImage"
          cd - > /dev/null
          rm -rf "$TEMP_DIR"
          continue
        }
        
        # Chercher l'icône dans plusieurs emplacements possibles
        ICON_FILE=""
        
        # 1. Chercher dans les emplacements standards
        for icon_path in \
          "squashfs-root/usr/share/icons/hicolor/256x256/apps/*.png" \
          "squashfs-root/usr/share/icons/hicolor/128x128/apps/*.png" \
          "squashfs-root/usr/share/icons/hicolor/*/apps/*.png" \
          "squashfs-root/usr/share/pixmaps/*.png" \
          "squashfs-root/*.png" \
          "squashfs-root/usr/share/icons/hicolor/scalable/apps/*.svg" \
          "squashfs-root/*.svg"; do
          FOUND=$(find squashfs-root -path "$icon_path" 2>/dev/null | head -1)
          if [ -n "$FOUND" ]; then
            ICON_FILE="$FOUND"
            break
          fi
        done
        
        # 2. Si pas trouvé, chercher n'importe quelle icône PNG/SVG
        if [ -z "$ICON_FILE" ]; then
          ICON_FILE=$(find squashfs-root -type f \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | \
            ${pkgs.gnugrep}/bin/grep -v "thumbnail" | head -1)
        fi
        
        if [ -n "$ICON_FILE" ] && [ -f "$ICON_FILE" ]; then
          ICON_EXT="''${ICON_FILE##*.}"
          mkdir -p "${iconsDir}"
          cp "$ICON_FILE" "${iconsDir}/$ICON_NAME.$ICON_EXT"
          echo "Icône extraite: ${iconsDir}/$ICON_NAME.$ICON_EXT"
        else
          echo "Aucune icône trouvée dans ${name}"
        fi
        
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
      else
        echo "${name} existe déjà, téléchargement ignoré."
      fi
    fi
  '';

  # Liste des AppImages activées (avec url OU githubRepo)
  enabledAppImages = lib.filterAttrs (name: app: app.enable && (app.url != "" || app.githubRepo != "")) cfg.apps;

  # Génère les fichiers .desktop pour chaque AppImage
  mkDesktopEntry = name: appCfg: lib.mkIf appCfg.desktopEntry.enable {
    "${appCfg.desktopEntry.name}" = {
      name = appCfg.desktopEntry.displayName;
      exec = "${appimagesDir}/${appCfg.filename}";
      icon = "${iconsDir}/${appCfg.desktopEntry.name}";
      comment = appCfg.desktopEntry.comment;
      categories = appCfg.desktopEntry.categories;
      mimeType = appCfg.desktopEntry.mimeTypes;
      terminal = false;
      type = "Application";
    };
  };

  # Type pour les options d'une AppImage
  appimageType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "cette AppImage";

      url = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "URL directe de téléchargement de l'AppImage (ignoré si githubRepo est défini)";
      };

      githubRepo = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Repo GitHub au format 'owner/repo' pour télécharger la dernière release";
        example = "imputnet/helium-linux";
      };

      githubAssetPattern = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Pattern pour filtrer les assets GitHub (ex: 'x86_64.AppImage')";
        example = "x86_64.AppImage";
      };

      filename = lib.mkOption {
        type = lib.types.str;
        description = "Nom du fichier AppImage";
      };

      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Si true, retélécharge l'AppImage à chaque switch";
      };

      desktopEntry = {
        enable = lib.mkEnableOption "l'entrée de bureau XDG";

        name = lib.mkOption {
          type = lib.types.str;
          description = "Nom du fichier .desktop (sans extension)";
        };

        displayName = lib.mkOption {
          type = lib.types.str;
          description = "Nom affiché dans le menu";
        };

        comment = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Description de l'application";
        };

        categories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "Utility" ];
          description = "Catégories XDG";
        };

        mimeTypes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Types MIME supportés par l'application";
        };
      };
    };
  };

in
{
  imports = [
    ./helium.nix
  ];

  options.appimages = {
    apps = lib.mkOption {
      type = lib.types.attrsOf appimageType;
      default = {};
      description = "Définitions des AppImages à gérer";
    };
  };

  config = lib.mkIf (enabledAppImages != {}) {
    # Crée le dossier AppImages
    home.file."AppImages/.keep".text = "";

    # Script d'activation pour télécharger les AppImages
    home.activation.downloadAppImages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      LOG_FILE="${appimagesDir}/appimages-install.log"
      
      # Fonction pour logger
      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
      }
      
      mkdir -p "${appimagesDir}"
      mkdir -p "${iconsDir}"
      
      log "=== Début de l'installation des AppImages ==="
      
      # Rediriger la sortie vers le fichier de log tout en l'affichant
      {
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkDownloadScript enabledAppImages)}
      } 2>&1 | while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" | tee -a "$LOG_FILE"
      done
      
      log "=== Fin de l'installation des AppImages ==="
      log "Logs disponibles dans: $LOG_FILE"
    '';

    # Génère les entrées .desktop
    xdg.desktopEntries = lib.mkMerge (lib.mapAttrsToList mkDesktopEntry enabledAppImages);
  };
}
