{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.jellyfin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Jellyfin container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/jellyfin";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";

    moviesDirectory = "/mnt/data/movies";
    showsDirectory = "/mnt/data/shows";
    musicDirectory = "/mnt/data/music";
    tvReplaysDirectory = "/mnt/data/tvreplays";
  in lib.mkIf config.host.containers.jellyfin.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/config 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "L ${caddySiteDirectory}/jellyfin.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "jellyfin.caddy" ''
          jellyfin.greep.fr {
            reverse_proxy jellyfin:8096
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers.jellyfin = {
      image = "ghcr.io/jellyfin/jellyfin";
      volumes = [
        "/dev/nvidia-caps:/dev/nvidia-caps"
        "/dev/nvidia0:/dev/nvidia0"
        "/dev/nvidiactl:/dev/nvidiactl"
        "/dev/nvidia-modeset:/dev/nvidia-modeset"
        "/dev/nvidia-uvm:/dev/nvidia-uvm"
        "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"

        "${directory}/config:/config"
        "${directory}/cache:/cache"
        #"${directory}/media-bar-list.txt:/jellyfin/jellyfin-web/avatars/list.txt:ro"

        "${moviesDirectory}:/media/films"
        "${showsDirectory}:/media/series"
        "${musicDirectory}:/media/music"
        "${tvReplaysDirectory}:/media/tvreplays"
      ];
      environment = {
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "https://jellyfin.greep.fr";
        NVIDIA_DRIVER_CAPABILITIES = "all";
        NVIDIA_VISIBLE_DEVICES = "all";
      };
      ports = [
        "8096:8096"
        "1900:1900/udp" # DLNA Discovery port
      ];
      networks = [ "caddy-bridge" ];
      extraOptions = [ "--gpus=all" ];
      dependsOn = [
        "caddy"
      ];
    };
  };
}