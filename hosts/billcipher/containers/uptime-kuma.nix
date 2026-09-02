{ config, lib, ... }:

{
  options.host = {
    containers.kuma = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Uptime Kuma container for this host";
      };
    };
  };

  config = let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/kuma";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";
  in lib.mkIf config.host.containers.prometheus.enable
  {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/kuma-data 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/uptime-kuma-greep.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "uptime-kuma-greep.caddy" ''
          status.greep.fr {
            route {
              crowdsec
            }
            import error-handler

            vars {
              websiteName "Status Greep"
            }

            #error 503 # Maintenance

            reverse_proxy uptime-kuma:3001 {
              fail_duration 30s
              unhealthy_status 503
            }
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers = {
      uptime-kuma = {
        image = "ghcr.io/louislam/uptime-kuma:2";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${directory}/kuma-data:/app/data"
        ];
        networks = [
          "caddy-bridge"
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        dependsOn = [
          "caddy"
        ];
      };
    };
  };
}