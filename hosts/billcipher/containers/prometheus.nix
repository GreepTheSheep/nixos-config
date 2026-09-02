{ config, lib, ... }:

{
  options.host = {
    containers.prometheus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Prometheus container for this host";
      };

      node-exporter = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Node exporter container for this host";
      };
    };
  };

  config = let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/prometheus";
  in lib.mkIf config.host.containers.prometheus.enable
  {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/prometheus-data 0755 ${user} users"
      "C+ ${directory}/prometheus-conf.yml 0755 ${user} users - ${(pkgs.formats.yaml { }).generate "prometheus-conf.yml" {
        scrape_configs = [
          {
            job_name = "node_billcipher";
            static_configs = [{targets = ["node-exporter:9100"];}];
          }
        ];
      }}"
    ];

    systemd.services.create-prometheus-network-network = {
      description = "Create prometheus-network docker network";
      after = [ "docker.service" ];
      before = [ "docker-prometheus.service" ];
      wantedBy = [ "docker-node-exporter.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create prometheus-network || true'";
      };
    };

    virtualisation.oci-containers.containers = {
      prometheus = {
        image = "ghcr.io/prometheus/prometheus";
        volumes = [
          "${directory}/prometheus-data:/prometheus"
          "${directory}/prometheus-conf.yml:/etc/prometheus/prometheus.yml:ro"
        ];
        networks = [
          "prometheus-network"
          "caddy-bridge"
        ];
        cmd = [
          "--config.file=/etc/prometheus/prometheus.yml"
          "--web.external-url=https://billcipher.greep.fr/prom/"
          "--web.route-prefix=/"
          "--storage.tsdb.path=/prometheus"
          "--web.console.libraries=/usr/share/prometheus/console_libraries"
          "--web.console.templates=/usr/share/prometheus/consoles"
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        dependsOn = [
          "caddy"
        ];
      };

      node-exporter = lib.mkIf config.host.containers.prometheus.node-exporter {
        image = "ghcr.io/prometheus/node-exporter";
        volumes = [
          "/:/host:ro,rslave"
        ];
        networks = [
          "prometheus-network"
        ];
        capabilities = {
          SYS_ADMIN = true;
        };
        cmd = [
          "--path.rootfs=/host"
        ];
        environment = {
          TZ = "Europe/Paris";
        };
      };
    };
  };
}