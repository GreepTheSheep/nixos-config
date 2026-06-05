{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.qbittorrent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable qbittorrent and services for this host";
      };

      enableXseed = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Cross-seed container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/qbittorrent";

    downloadsDirectory = "/mnt/localdata/arr-downloads";
  in lib.mkIf config.host.containers.qbittorrent.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/wireguard-config 0755 ${user} users"
      "d ${directory}/qbittorrent-config 0755 ${user} users"
      "d ${directory}/xseed-config 0755 ${user} users"
    ];

    virtualisation.oci-containers.containers = {
      wireguard = {
        image = "lscr.io/linuxserver/wireguard";
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/Paris";
        };
        user = "1000:1000";
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
        #ports = [
          #"6881:6881"
          #"6881:6881/udp"
        #];
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
        user = "1000:1000";
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

      cross-seed = lib.mkIf config.host.containers.qbittorrent.enableXseed {
        image = "ghcr.io/cross-seed/cross-seed:6";
        environment = {
          TZ = "Europe/Paris";
          PUID = "1000";
          GUID = "1000";
        };
        user = "1000:1000";
        volumes = [
          "${directory}/xseed-config:/config"
          "${downloadsDirectory}:/downloads"
        ];
        #ports = [
          #"2468:2468"
        #];
        dependsOn = [
          "qbittorrent"
        ];
        extraOptions = [
          "--network=container:wireguard"
        ];
        cmd = [
          "daemon"
        ];
      };
    };
  };
}