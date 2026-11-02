{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.host.containers.wikijs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable WikiJS container for this host";
    };
  };

  config =
    let
      user = config.nixos.system.user.defaultuser.name;
      home = config.users.users."${user}".home;
      directory = "${home}/docker-containers/wikijs";
      caddySiteDirectory = "${home}/docker-containers/caddy/sites";
    in
    lib.mkIf config.host.containers.wikijs.enable {
      systemd.tmpfiles.rules = lib.mkMerge [
        ([
          "d ${directory} 0755 ${user} users"
          "d ${directory}/config 0755 ${user} users"
          "d ${directory}/data 0755 ${user} users"
        ])
        (lib.mkIf config.host.containers.caddy.enable [
          "C+ ${caddySiteDirectory}/wikijs.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "wikijs.caddy" ''
            wiki.greep.fr {
              route {
                crowdsec
              }
              import error-handler

              vars {
                websiteName "Wiki Greep"
              }

              #error 503 # Maintenance

              reverse_proxy wikijs:3000 {
                fail_duration 30s
                unhealthy_status 503
              }
            }
          ''}"
        ])
      ];

      virtualisation.oci-containers.containers.wikijs = {
        image = "linuxserver/wikijs";
        volumes = [
          "${directory}/config:/config"
          "${directory}/data:/data"
        ];
        networks = [
          "caddy-bridge"
        ];
        environment = {
          TZ = "Europe/Paris";
          DB_TYPE = "sqlite";
        };
        dependsOn = [
          "caddy"
        ];
      };
    };
}
