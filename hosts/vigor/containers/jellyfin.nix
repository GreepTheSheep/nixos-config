{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.jellyfin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Jellyfin container for this host";
      };

      enableGPU = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GPU for the Jellyfin container";
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
        "d ${directory}/cache 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/jellyfin.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "jellyfin.caddy" ''
          jellyfin.greep.fr {
            import error-handler

            vars {
              websiteName "Jellyfin"
            }

            import hsts

            #error 503 # Maintenance

            reverse_proxy jellyfin:8096 {
              fail_duration 30s
              unhealthy_status 503
            }

            @primaryImages {
              path_regexp primaryImages ^/Items/[0-9a-zA-Z-]+/Images/Primary$
            }
            header @primaryImages -Content-Disposition

            basicauth /metrics* {
              jellyfin $2a$14$kAfOmNHCCWefnuzdRX9UeeiRHmvcjDg3W8Ko0oSq6wnS6eix.zZ8O
            }
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers.jellyfin = {
      image = "ghcr.io/jellyfin/jellyfin";
      volumes = [
        "${directory}/config:/config"
        "${directory}/cache:/cache"
        #"${directory}/media-bar-list.txt:/jellyfin/jellyfin-web/avatars/list.txt:ro"

        "${moviesDirectory}:/media/films"
        "${showsDirectory}:/media/series"
        "${musicDirectory}:/media/music"
        "${tvReplaysDirectory}:/media/tvreplays"
      ] ++ lib.optionals config.host.containers.jellyfin.enableGPU [
        "/dev/nvidia-caps:/dev/nvidia-caps"
        "/dev/nvidia0:/dev/nvidia0"
        "/dev/nvidiactl:/dev/nvidiactl"
        "/dev/nvidia-modeset:/dev/nvidia-modeset"
        "/dev/nvidia-uvm:/dev/nvidia-uvm"
        "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
      ];
      environment = {
        TZ = "Europe/Paris";
        JELLYFIN_PublishedServerUrl = "https://jellyfin.greep.fr";
        NVIDIA_DRIVER_CAPABILITIES = lib.mkIf config.host.containers.jellyfin.enableGPU "all";
        NVIDIA_VISIBLE_DEVICES = lib.mkIf config.host.containers.jellyfin.enableGPU "all";
      };
      ports = [
        "8096:8096"
        "1900:1900/udp" # DLNA Discovery port
      ];
      networks = [ "caddy-bridge" ];
      extraOptions = lib.mkIf config.host.containers.jellyfin.enableGPU [ "--device=nvidia.com/gpu=all" ];
      dependsOn = [
        "caddy"
      ];
    };
  };
}