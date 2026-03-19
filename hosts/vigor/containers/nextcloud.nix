{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.nextcloud = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable nextcloud container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/nextcloud";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";

    dataDirectory = "/mnt/data/nextcloud";
  in lib.mkIf config.host.containers.nextcloud.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/database 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "L ${caddySiteDirectory}/nextcloud.caddy - - - - ${pkgs.writeText "nextcloud.caddy" ''
          cloud.greep.fr {
            reverse_proxy nextcloud:80
          }
        ''}"
      ])
    ];

    sops.secrets = {
      "docker/nextcloud/nextcloud-database-password" = {};
      "docker/nextcloud/nextcloud-database-database" = {};
      "docker/nextcloud/nextcloud-database-user" = {};
    };

    sops.templates = {
      "nextcloud.env".content = ''
        MYSQL_PASSWORD=${config.sops.placeholder."docker/nextcloud/nextcloud-database-password"}
        MYSQL_DATABASE=${config.sops.placeholder."docker/nextcloud/nextcloud-database-database"}
        MYSQL_USER=${config.sops.placeholder."docker/nextcloud/nextcloud-database-user"}
        MYSQL_HOST=nextcloud-mariadb
        PHP_MEMORY_LIMIT=1G
        PHP_UPLOAD_LIMIT=90M
      '';
      "nextcloud-mariadb.env".content = ''
        MYSQL_PASSWORD=${config.sops.placeholder."docker/nextcloud/nextcloud-database-password"}
        MYSQL_DATABASE=${config.sops.placeholder."docker/nextcloud/nextcloud-database-database"}
        MYSQL_USER=${config.sops.placeholder."docker/nextcloud/nextcloud-database-user"}
      '';
    };

    virtualisation.oci-containers.containers = {
      "nextcloud-mariadb" = {
        image = "mariadb:lts";
        volumes = [
          "${directory}/database:/var/lib/mysql"
        ];
        environmentFiles = [
          config.sops.templates."nextcloud-mariadb.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        networks = [
          "nextcloud-network"
        ];
        cmd = [
          "--transaction-isolation=READ-COMMITTED"
          "--log-bin=binlog"
          "--binlog-format=ROW"
          "--innodb-lock-wait-timeout=86400"
          "--character-set-server=utf8mb4"
          "--collation-server=utf8mb4_bin"
        ];
      };

      nextcloud = {
        image = "nextcloud";
        volumes = [
          "${dataDirectory}:/var/www/html/data"
        ];
        environmentFiles = [
          config.sops.templates."nextcloud.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        networks = [
          "caddy-bridge"
          "nextcloud-network"
        ];
        dependsOn = [
          "nextcloud-mariadb"
          "caddy"
        ];
      };
    };
  };
}