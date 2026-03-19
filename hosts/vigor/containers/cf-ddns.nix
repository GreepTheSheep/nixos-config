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
      # TODO
    };
  in lib.mkIf config.host.containers.cfddns.enable {
    sops.secrets."docker/cfddns/api-token" = {};

    sops.templates."cfddns.env".content = ''
      CF_DDNS_API_TOKEN_1=${config.sops.placeholder."docker/cfddns/api-token"}
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