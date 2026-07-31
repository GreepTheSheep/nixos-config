{ config, lib, pkgs, ... }:

let
  cfg = config.homeManager.applications.gaming.nxapi;
  serviceCfg = cfg.service;
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

      service = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = ''
            Run nxapi Discord presence as a systemd user service in the
            background. Uses `nxapi nso presence` which updates your Discord
            activity with your Nintendo Switch presence.
          '';
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nxapi;
          defaultText = lib.literalExpression "pkgs.nxapi";
          description = "Package to use for the service (CLI or Electron app).";
        };

        presenceUrl = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "https://nxapi.example.com/api/presence";
          description = ''
            URL to fetch presence data from (ZncProxyApi server).
            If null, uses a friend Nintendo Account presence.
          '';
        };

        friendNsaId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "xxxxxxxxxxxxxxxx";
          description = ''
            NSA ID of the friend whose presence to show in Discord.
            Required if `presenceUrl` is not set.
          '';
        };

        account = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "friend-account";
          description = ''
            Nintendo Account name to use for fetching presence.
            The account must be authenticated via `nxapi users add`
            beforehand.
          '';
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "--no-sandbox" "--autostart" ];
          description = "Extra arguments to pass to `nxapi nso presence`.";
        };
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

    systemd.user.services.nxapi-presence = lib.mkIf serviceCfg.enable {
      Unit = {
        Description = "nxapi Nintendo Switch Discord presence";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.concatStringsSep " " (
          [ "${serviceCfg.package}/bin/nxapi" "nso" "presence" ]
          ++ lib.optionals (serviceCfg.account != null) [ "--user" serviceCfg.account ]
          ++ lib.optionals (serviceCfg.presenceUrl != null) [ "--friend-url" serviceCfg.presenceUrl ]
          ++ lib.optionals (serviceCfg.friendNsaId != null) [ "--friend-nsa-id" serviceCfg.friendNsaId ]
          ++ serviceCfg.extraArgs
        );
        Restart = "on-failure";
        RestartSec = 10;
        Environment = [
          "NXAPI_DATA_PATH=${cfg.dataPath}"
        ] ++ lib.optional (cfg.authClientId != null)
          "NXAPI_AUTH_CLIENT_ID=${cfg.authClientId}"
        ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.extraEnv;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}