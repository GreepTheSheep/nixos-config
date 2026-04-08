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

  config = let
    subDomains = [
      "vigor"
      "jellyfin"
      "jellyfin-requests"
      "immich"
      "cloud"
      "cdn"
    ];
    ipv4subDomains = [ "4.vigor" ];
    ipv6subDomains = [ "6.vigor" ];

    domain = "greep.fr";
  in lib.mkIf config.host.containers.cfddns.enable {
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
        DOMAINS = lib.concatMapStringsSep "," (sub: "${sub}.${domain}") subDomains;
        IP4_DOMAINS = lib.concatMapStringsSep "," (sub: "${sub}.${domain}") ipv4subDomains;
        IP6_DOMAINS = lib.concatMapStringsSep "," (sub: "${sub}.${domain}") ipv6subDomains;
        PROXIED = "!is(sub(vigor.greep.fr))";
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