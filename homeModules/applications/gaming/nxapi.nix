{ config, lib, pkgs, ... }:

let
  cfg = config.homeManager.applications.gaming.nxapi;
in
{
  options.homeManager = {
    applications.gaming.nxapi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nxapi (Nintendo Switch Online API CLI).";
      };

      enableElectronApp = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Install the nxapi Electron desktop app (heavier build from git).
          Note: build from git does not include the nxapi-auth client id
          required for direct Coral API access. Set `authClientId` if needed,
          or use the ZncProxyApi class instead of CoralApi.
        '';
      };

      dataPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.local/share/nxapi-nodejs";
        description = ''
          NXAPI_DATA_PATH location for user data (tokens, cache).
          Defaults to the Linux XDG convention.
        '';
      };

      authClientId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
        description = ''
          NXAPI_AUTH_CLIENT_ID (nxapi-auth client identifier).
          Required for direct Coral API access when building from source.
          Register a test OAuth client at
          https://nxapi-auth.fancy.org.uk/oauth/clients with scope
          `ca:gf ca:er ca:dr`. Not needed for Parental Controls data
          or when using ZncProxyApi.
        '';
      };

      extraEnv = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = { NXAPI_USER_AGENT = "my-script/1.0.0 (+https://github.com/...)"; };
        description = "Extra NXAPI_* environment variables to set.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nxapi ]
      ++ lib.optionals cfg.enableElectronApp [ pkgs.nxapi-electron ];

    home.sessionVariables = {
      NXAPI_DATA_PATH = cfg.dataPath;
    } // lib.optionalAttrs (cfg.authClientId != null) {
      NXAPI_AUTH_CLIENT_ID = cfg.authClientId;
    } // cfg.extraEnv;
  };
}