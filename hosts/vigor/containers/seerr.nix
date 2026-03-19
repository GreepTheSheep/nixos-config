{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.seerr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Seerr container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/seerr";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";
  in lib.mkIf config.host.containers.seerr.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/config 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "L ${caddySiteDirectory}/seerr.caddy - - - - ${pkgs.writeText "seerr.caddy" ''
          jellyfin-requests.greep.fr {
            reverse_proxy seerr:5055
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers.seerr = {
      # Port 5055
      image = "ghcr.io/seerr-team/seerr";
      volumes = [
        "${directory}/config:/config"
      ];
      environment = {
        TZ = "Europe/Paris";
        LOG_LEVEL = "debug";
      };
      networks = [ "caddy-bridge" ];
      extraOptions = [
        "--health-cmd=\"wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1\""
        "--health-start-period=20s"
        "--health-timeout=3s"
        "--health-interval=15s"
        "--health-retries=3"
      ];
    };
  };
}