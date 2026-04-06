{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.cfddns = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Cloudflare DDNS container for this host";
      };
    };
  };

  config = lib.mkIf config.host.containers.cfddns.enable {
    sops.secrets = {
      "docker/cfddns/api-token" = {};
      "docker/cfddns/auth-key" = {};
      "docker/cfddns/account-email" = {};
      "docker/cfddns/zone-id" = {};
    };

    sops.templates = {
      "cfddns-config.json".content = builtins.toJSON {
        accounts = [{
          authentication = {
            api_token = "${config.sops.placeholder."docker/cfddns/api-token"}";
            api_key = {
              auth_key = "${config.sops.placeholder."docker/cfddns/auth-key"}";
              account_email = "${config.sops.placeholder."docker/cfddns/account-email"}";
            };
          };
          zones = [
            {
              # A entries
              id = "${config.sops.placeholder."docker/cfddns/zone-id"}";
              name = "greep.fr";
              subdomains = [
                {
                  name = "vigor";
                  proxied = false;
                  type = "A";
                }
                {
                  name = "4.vigor";
                  proxied = false;
                  type = "A";
                }
                {
                  name = "jellyfin";
                  proxied = true;
                  type = "A";
                }
                {
                  name = "jellyfin-requests";
                  proxied = true;
                  type = "A";
                }
                {
                  name = "cloud";
                  proxied = true;
                  type = "A";
                }
                {
                  name = "immich";
                  proxied = true;
                  type = "A";
                }
                {
                  name = "cdn";
                  proxied = true;
                  type = "A";
                }
              ];
            }
            {
              # AAAA entries
              id = "${config.sops.placeholder."docker/cfddns/zone-id"}";
              name = "greep.fr";
              subdomains = [
                {
                  name = "vigor";
                  proxied = false;
                  type = "AAAA";
                }
                {
                  name = "6.vigor";
                  proxied = false;
                  type = "AAAA";
                }
                {
                  name = "jellyfin";
                  proxied = true;
                  type = "AAAA";
                }
                {
                  name = "jellyfin-requests";
                  proxied = true;
                  type = "AAAA";
                }
                {
                  name = "cloud";
                  proxied = true;
                  type = "AAAA";
                }
                {
                  name = "immich";
                  proxied = true;
                  type = "AAAA";
                }
                {
                  name = "cdn";
                  proxied = true;
                  type = "AAAA";
                }
              ];
            }
          ];
        }];
      };
    };

    virtualisation.oci-containers.containers."cloudflare-ddns" = {
      image = "ghcr.io/dimpen/cloudflare-ddns-next";
      user = "0:0";
      volumes = [
        "${config.sops.templates."cfddns-config.json".path}:/config.json:ro"
      ];
      environment = {
        TZ = "Europe/Paris";
      };
      cmd = [
        "--interval 300"
      ];
      extraOptions = [
        "--security-opt=no-new-privileges:true"
        "--network=host"
      ];
    };
  };
}