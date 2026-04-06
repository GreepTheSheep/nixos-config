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

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/cloudflare-ddns";

    cfddnsConfig = builtins.toJSON {
      accounts = [{
        zones = [{
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
  in lib.mkIf config.host.containers.cfddns.enable {
    sops.secrets."docker/cfddns/api-token" = {};
    sops.secrets."docker/cfddns/zone-id" = {};

    sops.templates."cfddns.env".content = ''
      CF_DDNS_API_TOKEN_1=${config.sops.placeholder."docker/cfddns/api-token"}
      CF_DDNS_ZONE_ID_1=${config.sops.placeholder."docker/cfddns/zone-id"}
    '';

    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "C+ ${directory}/config.json - - - - ${pkgs.writeText "cf-ddns-config.json" cfddnsConfig}"
    ];

    virtualisation.oci-containers.containers."cloudflare-ddns" = {
      image = "ghcr.io/dimpen/cloudflare-ddns-next";
      volumes = [
        "${directory}/config.json:/config.json:ro"
      ];
      environmentFiles = [
        config.sops.templates."cfddns.env".path
      ];
      environment = {
        TZ = "Europe/Paris";
      };
    };
  };
}