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
      "docker/cfddns/zone-id" = {};
    };

    sops.templates = {
      "cfddns-config.json".content = builtins.toJSON {
        accounts = [{
          authentication = {
            api_token = "${config.sops.placeholder."docker/cfddns/api-token"}";
            #api_key = {
            #  auth_key = "sdfgsdfgdfgsdfdfsdsf";
            #  account_email = "email@example.com";
            #};
          };
          zones = [{
            id = "${config.sops.placeholder."docker/cfddns/zone-id"}";
            name = "greep.fr";
            subdomains = [
              {
                name = "vigor";
                proxied = false;
                type = "A";
              }
              {
                name = "vigor";
                proxied = false;
                type = "AAAA";
              }
            ];
          }];
        }];
      };
    };

    virtualisation.oci-containers.containers."cloudflare-ddns" = {
      image = "ghcr.io/dimpen/cloudflare-ddns-next";
      volumes = [
        "${config.sops.templates."cfddns-config.json".path}:/config.json:ro"
      ];
      environment = {
        TZ = "Europe/Paris";
      };
    };
  };
}