{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.caddy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Caddy container for this host";
      };
    };
  };

  config =
  let
    directory = "${config.users.users."${config.nixos.system.user.defaultuser.name}".home}/docker-containers/caddy";
  in lib.mkIf config.host.containers.caddy.enable
  {
    sops.secrets = {
      "docker/caddy/cloudflare-acme-dns-apikey" = {};
      "gitea/registry-password" = {};
    };

    sops.templates."caddy-extraconf-cloudflare-acme".content = ''
      acme_dns cloudflare ${config.sops.placeholder."docker/caddy/cloudflare-acme-dns-apikey"}
    '';

    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/caddy-data 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/sites 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/extra-config 0755 ${config.nixos.system.user.defaultuser.name} users"

      "C+ ${directory}/extra-config/cloudflare-acme.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${config.sops.templates."caddy-extraconf-cloudflare-acme".path}"

      "C+ ${directory}/sites/billcipher.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "billcipher.caddy" ''
        4.billcipher.greep.fr, 6.billcipher.greep.fr, billcipher.greep.fr {
          import error-handler
          ${lib.optionalString config.host.containers.backrest.enable ''
            redir /backrest /backrest/
            handle_path /backrest/* {
              vars {
                websiteName "Backrest"
              }

              #error 503 # Maintenance

              reverse_proxy backrest:9898 {
                fail_duration 30s
                unhealthy_status 503
              }
            }
          ''}

          ${lib.optionalString config.host.containers.prometheus.enable ''
            redir /prom /prom/
            handle /prom/* {
              vars {
                websiteName "Prometheus"
              }

              #error 503 # Maintenance

              reverse_proxy prometheus:9090 {
                fail_duration 30s
                unhealthy_status 503
              }
            }
          ''}

          ${lib.optionalString config.host.containers.uptime-kuma.enable ''
            redir /kuma /kuma/
            handle_path /kuma/* {
              vars {
                websiteName "Uptime Kuma"
              }

              header -X-Frame-Options
              header X-Frame-Options "ALLOW-FROM https://jellyfin.greep.fr"

              #error 503 # Maintenance

              reverse_proxy uptime-kuma:3001 {
                fail_duration 30s
                unhealthy_status 503
              }
            }
          ''}

          handle /ip {
            respond <<HTML
            client_ip: {client_ip}
            remote_ip: {remote_ip}
            remote_host: {remote_host}
            X-Forwarded-For: {header.X-Forwarded-For}
            CF-Connecting-IP: {header.CF-Connecting-IP}
            HTML 200
          }

          handle / {
            root * {$TEMPLATES_DIR}/server-motd
            file_server
            rewrite * {labels.2}.html
          }
        }
      ''}"
    ];

    systemd.services.create-caddy-bridge-network = {
      description = "Create caddy-bridge docker network";
      after = [ "docker.service" ];
      before = [ "docker-caddy.service" ];
      wantedBy = [ "docker-caddy.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create caddy-bridge || true'";
      };
    };

    virtualisation.oci-containers.containers.caddy = {
      image = "git.greep.fr/greep/caddy";
      login = {
        registry = "git.greep.fr";
        username = "greep";
        passwordFile = config.sops.secrets."gitea/registry-password".path;
      };
      hostname = config.networking.hostName;
      ports = [
        "80:80"
        "443:443"
        "443:443/udp"
      ];
      volumes = [
        "${directory}/caddy-data:/data/caddy"
        "${directory}/sites:/etc/caddy/sites"
        "${directory}/extra-config:/etc/caddy/config.d"
      ];
      networks = [ "caddy-bridge" ];
      extraOptions = [
        "--security-opt=no-new-privileges:true"
      ];
    };

    nixos.system.firewall = {
      extraAllowedTCPPorts = [ 80 443 ];
      extraAllowedUDPPorts = [ 443 ];
    };
  };
}