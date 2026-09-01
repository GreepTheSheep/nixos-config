{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.privatebin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Privatebin container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/privatebin";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";
  in lib.mkIf config.host.containers.privatebin.enable {


    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/data 0755 ${user} users"
        "C+ ${directory}/conf.php 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "privatebin-conf.php" ''
          [main]
          basepath = "https://pb.greep.fr/"
          discussion = false
          burnafterreadingselected = true
          defaultformatter = "markdown"
          syntaxhighlightingtheme = "sunburst"
          template = "bootstrap-dark-page"
          languageselection = true
          qrcode = true

          [expire]
          default = "1day"
          [expire_options]
          5min = 300
          10min = 600
          1hour = 3600
          1day = 86400
          1week = 604800
          1month = 2592000

          [formatter_options]
          plaintext = "Plain Text"
          syntaxhighlighting = "Source Code"
          markdown = "Markdown"

          [traffic]
          limit = 10

          [purge]
          limit = 300
          batchsize = 10
          class = Filesystem
          [model_options]
          dir = PATH "data"
        ''}"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/privatebin.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "privatebin.caddy" ''
          pb.greep.fr {
            route {
              crowdsec
            }
            import error-handler

            vars {
              websiteName "Privatebin"
            }

            #error 503 # Maintenance

            reverse_proxy privatebin:8080 {
              fail_duration 30s
              unhealthy_status 503
            }
          }
        ''}"
      ])
    ];

    virtualisation.oci-containers.containers = {
      privatebin = {
        image = "ghcr.io/privatebin/nginx-fpm-alpine";
        volumes = [
          "${directory}/data:/srv/data"
          "${directory}/conf.php:/srv/cfg/conf.php:ro"
        ];
        networks = [
          "caddy-bridge"
        ];
        dependsOn = [
          "caddy"
        ];
      };
    };
  };
}