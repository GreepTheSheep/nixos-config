{ config, lib, ... }:

{
  options.host = {
    containers.deemix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Deemix container for this host";
      };
    };
  };

  config =
    let
      user = config.nixos.system.user.defaultuser.name;
      home = config.users.users."${user}".home;
      directory = "${home}/docker-containers/deemix";

      musicDirectory = "/mnt/data/music";
    in
    lib.mkIf config.host.containers.deemix.enable {
      systemd.tmpfiles.rules = [
        "d ${directory} 0755 ${config.nixos.system.user.defaultuser.name} users"
        "d ${directory}/config 0755 ${config.nixos.system.user.defaultuser.name} users"
      ];

      virtualisation.oci-containers.containers.deemix = {
        image = "ghcr.io/bambanah/deemix";
        volumes = [
          "${directory}/config:/config"
          "${musicDirectory}:/downloads"
        ];
        networks = [ "caddy-bridge" ];
        user = "1000:1000";
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
      };
    };
}
