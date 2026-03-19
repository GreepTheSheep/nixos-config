{ config, lib, ... }:

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
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/caddy-data 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/sites 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/templates 0755 ${config.nixos.system.user.defaultuser.name} users"

      "L ${directory}/Caddyfile - - - - ${pkgs.writeText "Caddyfile" ''
        {
          servers {
            trusted_proxies static private_ranges
            trusted_proxies cloudflare {
              interval 12h
              timeout 15s
            }
          }
        }

        (hsts) {
          header Strict-Transport-Security "max-age=63072000; includeSubDomains"
        }

        (cloudflare-real-ip) {
          @noIPv6 header !CF-Connecting-IPv6
          header_up @noIPv6 X-Forwarded-For {http.request.header.CF-Connecting-IP}
          header_up X-Forwarded-For {http.request.header.CF-Connecting-IPv6}
          header_up @noIPv6 X-Real-IP {http.request.header.CF-Connecting-IP}
          header_up X-Real-IP {http.request.header.CF-Connecting-IPv6}
          header_up X-Forwarded-Proto {scheme}
        }

        (error-handler) {
          handle_errors {
            root * /
            templates
            file_server
            @maintenance expression {http.error.status_code} == 503
            handle @maintenance {
              rewrite * {$TEMPLATES_DIR}/maintenance.html
            }
            handle {
              rewrite * {$TEMPLATES_DIR}/error.html
            }
          }
        }

        (allow_insecure_ssl) {
          transport http {
            tls
            tls_insecure_skip_verify
          }
        }

        import {$SITES_DIR}/*.caddy
      ''}"

      "L ${directory}/sites/vigor.caddy - - - - ${pkgs.writeText "vigor.caddy" ''
        4.vigor.greep.fr, 6.vigor.greep.fr, vigor.greep.fr {
          ${lib.optionalString config.host.containers.arr.enable ''
            redir /prowlarr /prowlarr/
            handle_path /prowlarr/* {
              reverse_proxy prowlarr:9696
            }

            redir /radarr /radarr/
            handle_path /radarr/* {
              reverse_proxy radarr:7878
            }

            redir /sonarr /sonarr/
            handle_path /sonarr/* {
              reverse_proxy sonarr:8989
            }

            redir /qbit /qbit/
            handle_path /qbit/* {
              reverse_proxy wireguard:8686 {
                header_up Host wireguard:8686
                header_up X-Forwarded-Host {host}:{hostport}
                header_up -Origin
                header_up -Referer
              }
            }
          ''}

          handle {
            root * {$TEMPLATES_DIR}/server-motd
            file_server
            rewrite * {labels.2}.html
          }
        }
      ''}"
    ];

    sops.secrets."gitea/registry-password" = {};

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
        "${directory}/Caddyfile:/etc/caddy/Caddyfile"
        "${directory}/sites:/etc/caddy/sites"
        "${directory}/templates:/etc/caddy/templates"
      ];
      networks = [ "caddy-bridge" ];
      environment = {
        SITES_DIR = "/etc/caddy/sites";
        TEMPLATES_DIR = "/etc/caddy/templates";
      };
    };

    nixos.system.firewall = {
      extraAllowedTCPPorts = [ 80 443 ];
      extraAllowedUDPPorts = [ 443 ];
    };
  };
}