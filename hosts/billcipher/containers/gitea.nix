{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.gitea = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Gitea container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/gitea";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";
  in lib.mkIf config.host.containers.gitea.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/gitea_data 0755 ${user} users"
        "d ${directory}/database 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/gitea.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "gitea.caddy" ''
          git.greep.fr {
            route {
              crowdsec
            }
            import error-handler

            vars {
              websiteName "Gitea"
            }

            #error 503 # Maintenance

            reverse_proxy gitea:3000 {
              fail_duration 30s
              unhealthy_status 503
            }
          }
          pages.greep.fr {
            route {
              crowdsec
            }
            import error-handler

            vars {
              websiteName "Gitea Pages"
            }

            #error 503 # Maintenance

            reverse_proxy gitea-pages:8000 {
              fail_duration 30s
              unhealthy_status 503
            }
          }
        ''}"
      ])
    ];

    sops.secrets = {
      "docker/gitea/database-password" = {};
      "docker/gitea/pages-token" = {};
      "docker/gitea/runner-registration-token" = {};
    };

    sops.templates = {
      "gitea.env".content = ''
        GITEA__database__PASSWD=${config.sops.placeholder."docker/gitea/database-password"}
      '';
      "gitea-mariadb.env".content = ''
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."docker/gitea/database-password"}
        MYSQL_PASSWORD=${config.sops.placeholder."docker/gitea/database-password"}
      '';
      "gitea-pages.env".content = ''
        GITEA_PAGES_TOKEN=${config.sops.placeholder."docker/gitea/pages-token"}
      '';
      "gitea-act.env".content = ''
        GITEA_RUNNER_REGISTRATION_TOKEN=${config.sops.placeholder."docker/gitea/runner-registration-token"}
      '';
    };

    systemd.services.create-gitea-network-network = {
      description = "Create gitea-network docker network";
      after = [ "docker.service" ];
      before = [ "docker-gitea-mariadb.service" ];
      wantedBy = [ "docker-gitea-mariadb.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create gitea-network || true'";
      };
    };

    virtualisation.oci-containers.containers = {
      "gitea-mariadb" = {
        image = "mariadb:lts";
        volumes = [
          "${directory}/database:/var/lib/mysql"
        ];
        environmentFiles = [
          config.sops.templates."gitea-mariadb.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
          MYSQL_USER = "gitea";
          MYSQL_DATABASE = "gitea";
        };
        networks = [
          "gitea-network"
        ];
      };

      gitea = {
        image = "gitea/gitea";
        volumes = [
          "${directory}/gitea_data:/data"
        ];
        environmentFiles = [
          config.sops.templates."gitea.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
          USER_UID = "1000";
          USER_GID = "1000";
          GITEA__database__DB_TYPE = "mysql";
          GITEA__database__HOST = "gitea-mariadb:3306";
          GITEA__database__NAME = "gitea";
          GITEA__database__USER = "gitea";
        };
        ports = [
          "3000:3000"
        ];
        extraOptions = [
          "--health-cmd=curl --silent --fail http://localhost:3000"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
        networks = [
          "caddy-bridge"
          "gitea-network"
        ];
        dependsOn = [
          "gitea-mariadb"
          "caddy"
        ];
      };

      "gitea-pages" = {
        image = "ghcr.io/deadnews/gitea-pages";
        environmentFiles = [
          config.sops.templates."gitea-pages.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
          GITEA_PAGES_SERVER = "http://gitea:3000";
        };
        networks = [
          "caddy-bridge"
          "gitea-network"
        ];
        dependsOn = [
          "gitea"
        ];
      };

      "gitea-act-runner" = {
        image = "gitea/act_runner";
        environmentFiles = [
          config.sops.templates."gitea-act.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
          GITEA_INSTANCE_URL = "https://git.greep.fr";
          GITEA_RUNNER_NAME = "BillCipher";
        };
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${directory}/gitea_act:/data"
        ];
        networks = [
          "gitea-network"
        ];
        dependsOn = [
          "gitea"
        ];
      };
    };
  };
}