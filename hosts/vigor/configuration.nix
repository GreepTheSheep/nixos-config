{ lib, ... }:

{
  options.host = {
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a laptop ?";
    };

    isVM = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a VM ?";
    };

    isLiveIso = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a Live ISO ?";
    };

    nixpkgs = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "unstable"
      ];
      default = "stable";
      description = "Nixpkgs channel to use for this host.";
    };
  };

  config = {
    host.containers.enable = true;

    nixos.base.tools = {
      scrutiny = {
        enable = true;
        openFirewall = true;
      };
    };

    nixos.desktop.enable = false;

    nixos.hardware = {
      amdcpu.enable = true;
      nvidiagpu.enable = true;
    };

    nixos.system = {
      nixos.garbageCollect = true;
      secureboot.enable = true;

      serviceWatchdog = {
        enable = true;
        services = [
          "create-arr-stack-network"
          "docker-flaresolverr"
          "docker-prowlarr"
          "docker-radarr"
          "docker-sonarr"
          "docker-backrest"
          "create-caddy-bridge-network"
          "docker-caddy"
          "docker-cloudflare-ddns"
          "docker-crowdsec"
          "docker-h5ai"
          "create-immich-network-network"
          "docker-immich-machine-learning"
          "docker-immich-redis"
          "docker-immich-postgres"
          "docker-immich"
          "docker-jellyfin"
          "create-nextcloud-network-network"
          "docker-nextcloud-mariadb"
          "docker-nextcloud"
          "docker-node-exporter"
          "docker-dgcm-exporter"
          "docker-wireguard"
          "docker-qbittorrent"
          "docker-cross-seed"
          "docker-seerr"
          "docker-tangled-discordbot"
          "docker-watchtower"
        ];
      };

      user.defaultuser = {
        pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
      };

      motd = {
        enable = true;
        content = builtins.readFile ./motd;
      };
    };

    nixos.userEnvironment.enable = false;

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
    };

    nixos.server = {
      vscode-server.external = true;
      samba = {
        enable = true;
        shares = [
          {
            name = "movies";
            path = "/mnt/data/movies";
          }
          {
            name = "shows";
            path = "/mnt/data/shows";
          }
          {
            name = "music";
            path = "/mnt/data/music";
          }
          {
            name = "tvreplays";
            path = "/mnt/data/tvreplays";
          }
          {
            name = "localdata";
            path = "/mnt/localdata";
            browsable = false;
            readonly = false;
            guest = false;
            users = "greep";
          }
          {
            name = "cdn";
            path = "/mnt/data/cdn";
            browsable = false;
            readonly = false;
            guest = false;
            users = "greep";
          }
        ];
      };
    };
  };
}
