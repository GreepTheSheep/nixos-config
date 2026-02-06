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
      else
        echo "${name} existe déjà, téléchargement ignoré."
      fi
    fi
  '';

  # Liste des AppImages activées (avec url OU githubRepo)
  enabledAppImages = lib.filterAttrs (name: app: app.enable && (app.url != "" || app.githubRepo != "")) cfg.apps;

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
    # Active appimaged pour l'intégration automatique
    services.appimagekit = {
      enable = true;
    };

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
      log "appimaged intégrera automatiquement les AppImages (icônes + .desktop)"
    '';
  };
}
