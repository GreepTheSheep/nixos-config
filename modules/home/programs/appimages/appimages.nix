{ config, lib, pkgs, ... }:

let
  cfg = config.appimages;
  appimagesDir = "${config.home.homeDirectory}/AppImages";

  # Génère le script de téléchargement pour une AppImage
  mkDownloadScript = name: appCfg: 
    let
      isGitHub = appCfg.githubRepo != "";
      # Pattern pour filtrer les assets (ex: "x86_64.AppImage")
      assetPattern = if appCfg.githubAssetPattern != "" then appCfg.githubAssetPattern else ".AppImage";
    in ''
    APPIMAGE_PATH="${appimagesDir}/${appCfg.filename}"
    ICON_PATH="${appimagesDir}/${name}.png"
    
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
        
        # Extraction de l'icône
        echo "Extraction de l'icône pour ${name}..."
        mkdir -p "${appimagesDir}/tmp_${name}"
        cd "${appimagesDir}/tmp_${name}"
        
        # Tenter d'extraire .DirIcon
        "$APPIMAGE_PATH" --appimage-extract .DirIcon > /dev/null 2>&1
        
        if [ -e "squashfs-root/.DirIcon" ]; then
          # .DirIcon est souvent un lien symbolique
          if [ -L "squashfs-root/.DirIcon" ]; then
            ICON_TARGET=$(readlink "squashfs-root/.DirIcon")
            "$APPIMAGE_PATH" --appimage-extract "$ICON_TARGET" > /dev/null 2>&1
            SRC_ICON="squashfs-root/$ICON_TARGET"
          else
            SRC_ICON="squashfs-root/.DirIcon"
          fi
          
          if [ -f "$SRC_ICON" ]; then
            echo "Conversion de l'icône en PNG..."
            ${pkgs.imagemagick}/bin/convert "$SRC_ICON" "$ICON_PATH"
            echo "Icône sauvegardée: $ICON_PATH"
          else
            echo "Attention: Impossible de trouver le fichier icône cible"
          fi
        else
          echo "Attention: .DirIcon non trouvé dans l'AppImage"
        fi
        
        # Nettoyage
        cd "${appimagesDir}"
        rm -rf "${appimagesDir}/tmp_${name}"
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
      exec = "${appimagesDir}/${appCfg.filename} ${appCfg.desktopEntry.execArgs}";
      icon = if appCfg.desktopEntry.icon != "" then appCfg.desktopEntry.icon else "${appimagesDir}/${name}.png";
      comment = appCfg.desktopEntry.comment;
      categories = appCfg.desktopEntry.categories;
      mimeType = appCfg.desktopEntry.mimeTypes;
      terminal = false;
      type = "Application";
      actions = lib.mapAttrs (actionName: actionCfg: {
        name = actionCfg.name;
        exec = "${appimagesDir}/${appCfg.filename} ${actionCfg.execArgs}";
      }) appCfg.desktopEntry.actions;
    };
  };

  # Type pour les actions .desktop
  actionType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Nom de l'action affiché dans le menu";
      };
      execArgs = lib.mkOption {
        type = lib.types.str;
        description = "Arguments à passer à l'exécutable pour cette action";
      };
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

        execArgs = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Arguments à passer à l'exécutable (ex: %U pour les URLs, %F pour les fichiers)";
        };

        icon = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Icône de l'application (nom du thème ou chemin absolu)";
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

        actions = lib.mkOption {
          type = lib.types.attrsOf actionType;
          default = {};
          description = "Actions supplémentaires (clic droit)";
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
