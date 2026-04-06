{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.backrest = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable backrest container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/backrest";

    dataDirectory = "/mnt/data";
    repoDirectory = "/mnt/localdata/backrest";
  in lib.mkIf config.host.containers.backrest.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/backrest-data 0755 ${user} users"
    ];

    virtualisation.oci-containers.containers.backrest = {
      image = "garethgeorge/backrest";
      hostname = "backrest";
      volumes = [
        "${directory}/backrest-data/data:/data"
        "${directory}/backrest-data/config:/config"
        "${directory}/backrest-data/cache:/cache"
        "${directory}/backrest-data/tmp:/tmp"
        "${directory}/backrest-data/rclone:/root/.config/rclone"
        "${directory}/ssh_config:/etc/ssh/ssh_config:ro"
        "${directory}/ssh_known_hosts:/etc/ssh/ssh_known_hosts:ro"
        "${dataDirectory}/immich-lib:/userdata/immich:ro"
        "${dataDirectory}/nextcloud:/userdata/nextcloud:ro"
        "${repoDirectory}:/repos"
      ];
      environment = {
        BACKREST_DATA = "/data";
        BACKREST_CONFIG = "/config/config.json";
        XDG_CACHE_HOME = "/cache";
        TMPDIR = "/tmp";
        TZ = "Europe/Paris";
      };
      networks = [ "caddy-bridge" ];
      dependsOn = [
        "caddy"
      ];
    };
  };
}