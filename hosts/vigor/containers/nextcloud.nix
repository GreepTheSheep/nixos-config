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
        "d ${directory}/app 0755 ${user} users"
        "d ${directory}/database 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/nextcloud.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "nextcloud.caddy" ''
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
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."docker/nextcloud/nextcloud-database-password"}
        MYSQL_PASSWORD=${config.sops.placeholder."docker/nextcloud/nextcloud-database-password"}
        MYSQL_DATABASE=${config.sops.placeholder."docker/nextcloud/nextcloud-database-database"}
        MYSQL_USER=${config.sops.placeholder."docker/nextcloud/nextcloud-database-user"}
      '';
    };

    systemd.services.create-nextcloud-network-network = {
      description = "Create nextcloud-network docker network";
      after = [ "docker.service" ];
      before = [ "docker-nextcloud-mariadb.service" ];
      wantedBy = [ "docker-nextcloud-mariadb.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create nextcloud-network || true'";
      };
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
        entrypoint = "/bin/bash";
        cmd = [
          "-c"
          "apt-get update && apt-get install ffmpeg curl -y && /entrypoint.sh apache2-foreground"
        ];
        volumes = [
          "${directory}/app:/var/www/html"
          "${dataDirectory}:/var/www/html/data"
        ];
        environmentFiles = [
          config.sops.templates."nextcloud.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        ports = [
          "8001:80"
        ];
        extraOptions = [
          "--health-cmd=curl --silent --fail http://localhost:80"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
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