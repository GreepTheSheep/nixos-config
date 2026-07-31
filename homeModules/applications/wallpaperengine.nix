{ config, lib, pkgs, ... }:

let
  cfg = config.homeManager.applications.wallpaperengine;

  wallpapersOpts = lib.types.submodule {
    options = {
      wallpaperId = lib.mkOption { type = lib.types.str; };
      monitor = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        description = ''
          Monitor to display the wallpaper on, as a KMS connector name
          (e.g. "DP-4", "HDMI-A-1"). Set to "auto" to resolve the first
          connected DRM connector at service startup, useful when the
          kernel assigns unstable DP-x names across reboots.
        '';
      };
      extraOptions = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
      silentAudio = lib.mkOption { type = lib.types.bool; default = true; };
    };
  };

  hasAuto = lib.any (w: w.monitor == "auto") cfg.wallpapers;

  # Build the per-wallpaper argument string for linux-wallpaperengine.
  # When monitor == "auto", the literal string __AUTO_MONITOR__ is emitted
  # as the --screen-root value and the wrapper script substitutes it at
  # runtime with the first connected DRM connector name.
  wallpaperArgsString = w:
    lib.concatStringsSep " " (
      [ "--screen-root" (if w.monitor == "auto" then "__AUTO_MONITOR__" else w.monitor) ]
      ++ w.extraOptions
      ++ [ "--bg" w.wallpaperId ]
    );

  wrapper = pkgs.writeShellScriptBin "linux-wallpaperengine-auto" ''
    set -eu
    MON=$(grep -l '^connected$' /sys/class/drm/card*-*/status 2>/dev/null \
      | head -n1 \
      | xargs -n1 dirname \
      | xargs -n1 basename \
      | sed 's/^card[0-9]*-//')
    if [ -z "$MON" ]; then
      echo "linux-wallpaperengine-auto: no connected DRM connector found" >&2
      exit 1
    fi
    ARGS=${lib.escapeShellArg (lib.concatStringsSep " "
      (lib.optional (cfg.assetsPath != null) "--assets-dir ${cfg.assetsPath}"
       ++ map wallpaperArgsString cfg.wallpapers))}
    ARGS="''${ARGS//__AUTO_MONITOR__/$MON}"
    exec ${lib.getExe pkgs.linux-wallpaperengine} $ARGS
  '';
in
{
  options.homeManager = {
    applications.wallpaperengine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable Linux-WallpaperEngine. Wallpaper Engine must be installed via Steam.";
      };

      assetsPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/wallpaper_engine/assets";
        description = "Wallpaper Engine assets full path.";
      };

      wallpapers = lib.mkOption {
        type = lib.types.listOf wallpapersOpts;
        example = [
          {
            wallpaperId = "3295216327";
            monitor = "HDMI-A-1";
          }
        ];
        description = "List of wallpapers.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.linux-wallpaperengine = {
      enable = true;
      assetsPath = cfg.assetsPath;
      wallpapers = map (w: {
        inherit (w) wallpaperId monitor extraOptions;
        audio.silent = w.silentAudio;
      }) cfg.wallpapers;
    };

    # When any wallpaper uses monitor = "auto", override the generated
    # ExecStart so the wrapper script resolves the connector name at
    # runtime (substituting __AUTO_MONITOR__ placeholders).
    systemd.user.services.linux-wallpaperengine.Service.ExecStart =
      lib.mkIf hasAuto (lib.mkForce (lib.getExe wrapper));
  };
}