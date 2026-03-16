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
    ];

    sops.secrets."gitea/registry-password" = {};

    virtualisation.oci-containers.containers.caddy = {
      image = "git.greep.fr/greep/caddy";
      login = {
        registry = "https://git.greep.fr";
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
      extraOptions = [
        "container_name: caddy"
        "restart: always"
      ];
    };
  };
}