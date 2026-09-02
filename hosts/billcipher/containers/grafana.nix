{ config, lib, ... }:

{
  options.host = {
    containers.grafana = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Grafana container for this host";
      };
    };
  };

  config = let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/grafana";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";
  in lib.mkIf config.host.containers.prometheus.enable
  {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/grafana-data 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/grafana.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "grafana.caddy" ''
          grafana.greep.fr {
            route {
              crowdsec
            }
            import error-handler

            vars {
              websiteName "Grafana"
            }

            #error 503 # Maintenance

            reverse_proxy grafana:7100 {
              fail_duration 30s
              unhealthy_status 503
            }
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers = {
      grafana = {
        image = "grafana/grafana";
        volumes = [
          "${directory}/grafana-data:/var/lib/grafana"
        ];
        networks = [
          "caddy-bridge"
        ];
        environment = {
          TZ = "Europe/Paris";
          GF_INSTALL_PLUGINS = "grafana-clock-panel, yesoreyeram-infinity-datasource";
          GF_SERVER_ROOT_URL = "https://grafana.greep.fr/";
          GF_SERVER_DOMAIN = "grafana.greep.fr";
          GF_SERVER_HTTP_PORT = "7100";
        };
        dependsOn = [
          "caddy"
        ];
      };
    };
  };
}