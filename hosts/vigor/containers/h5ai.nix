{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.h5ai = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable h5ai container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/h5ai";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";

    dataDirectory = "/mnt/data/cdn";
  in lib.mkIf config.host.containers.h5ai.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/config 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "L ${caddySiteDirectory}/h5ai.caddy - - - - ${pkgs.writeText "h5ai.caddy" ''
          cdn.greep.fr {
            reverse_proxy h5ai:80
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers.h5ai = {
      image = "awesometic/h5ai";
      serviceName = "h5ai-cdn.greep.fr";
      volumes = [
        "${directory}/config:/config"
        "${dataDirectory}:/h5ai"
      ];
      environment = {
        TZ = "Europe/Paris";
      };
      networks = [ "caddy-bridge" ];
    };
  };
}