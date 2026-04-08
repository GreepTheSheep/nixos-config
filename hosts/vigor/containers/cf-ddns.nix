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
    };

    sops.templates = {
      "cfddns-token.env".content = ''
        CLOUDFLARE_API_TOKEN=${config.sops.placeholder."docker/cfddns/api-token"}
      '';
    };

    virtualisation.oci-containers.containers."cloudflare-ddns" = {
      image = "timothyjmiller/cloudflare-ddns";
      environmentFiles = [
        config.sops.templates."cfddns-token.env".path
      ];
      environment = {
        TZ = "Europe/Paris";
        DOMAINS = "vigor.greep.fr,cdn.greep.fr,cloud.greep.fr,immich.greep.fr,jellyfin.greep.fr,jellyfin-requests.greep.fr";
        IP4_DOMAINS = "4.vigor.greep.fr";
        IP6_DOMAINS = "6.vigor.greep.fr";
        PROXIED = "!is(sub(vigor.greep.fr)";
        IP4_PROVIDER = "url:https://ipv4.getip.ovh/txt";
        IP6_PROVIDER = "url:https://ipv6.getip.ovh/txt";
      };
      extraOptions = [
        "--security-opt=no-new-privileges:true"
        "--network=host"
      ];
    };
  };
}