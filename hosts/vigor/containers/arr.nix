{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.arr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable *arr stack containers & qbittorrent for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/arr-stack";

    moviesDirectory = "/mnt/data/movies";
    showsDirectory = "/mnt/data/shows";
    downloadsDirectory = "/mnt/localdata/arr-downloads";
  in lib.mkIf config.host.containers.arr.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/prowlarr-config 0755 ${user} users"
      "d ${directory}/radarr-config 0755 ${user} users"
      "d ${directory}/sonarr-config 0755 ${user} users"
      "d ${directory}/wireguard-config 0755 ${user} users"
      "d ${directory}/qbittorrent-config 0755 ${user} users"
    ];

    systemd.services.create-arr-stack-network = {
      description = "Create arr-stack docker network";
      after = [ "docker.service" ];
      before = [ "docker-flaresolverr.service" ];
      wantedBy = [ "docker-flaresolverr.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create arr-stack || true'";
      };
    };

    virtualisation.oci-containers.containers = {
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr";
        environment = {
          TZ = "Europe/Paris";
          LANG = "fr-FR";
        };
        networks = [
          "arr-stack"
        ];
      };

      prowlarr = {
        # Port 9696
        image = "lscr.io/linuxserver/prowlarr";
        volumes = [
          "${directory}/prowlarr-config:/config"
        ];
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
        networks = [
          "caddy-bridge"
          "arr-stack"
        ];
        dependsOn = [
          "flaresolverr"
          "caddy"
        ];
      };

      radarr = {
        # Port 7878
        image = "lscr.io/linuxserver/radarr";
        volumes = [
          "${directory}/radarr-config:/config"
          "${moviesDirectory}:/movies"
          "${downloadsDirectory}:/downloads"
        ];
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
        networks = [
          "caddy-bridge"
          "arr-stack"
        ];
        dependsOn = [
          "prowlarr"
          "caddy"
        ];
      };

      sonarr = {
        # Port 8989
        image = "lscr.io/linuxserver/sonarr";
        volumes = [
          "${directory}/sonarr-config:/config"
          "${showsDirectory}:/shows"
          "${downloadsDirectory}:/downloads"
        ];
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
        networks = [
          "caddy-bridge"
          "arr-stack"
        ];
        dependsOn = [
          "prowlarr"
          "caddy"
        ];
      };

      wireguard = {
        image = "lscr.io/linuxserver/wireguard";
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
        volumes = [
          "${directory}/wireguard-config:/config"
        ];
        capabilities = {
          NET_ADMIN = true;
        };
        networks = [
          "caddy-bridge"
          "arr-stack"
        ];
        ports = [
          "6881:6881"
          "6881:6881/udp"
        ];
        extraOptions = [
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        ];
        dependsOn = [
          "caddy"
        ];
      };

      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent";
        environment = {
          TZ = "Europe/Paris";
          WEBUI_PORT = "8686";
          PUID = "1000";
          GUID = "1000";
        };
        volumes = [
          "${directory}/qbittorrent-config:/config"
          "${downloadsDirectory}:/downloads"
        ];
        dependsOn = [
          "wireguard"
        ];
        extraOptions = [
          "--network=container:wireguard"
        ];
      };
    };

    nixos.system.firewall = {
      extraAllowedTCPPorts = [ 6881 ];
      extraAllowedUDPPorts = [ 6881 ];
    };
  };
}