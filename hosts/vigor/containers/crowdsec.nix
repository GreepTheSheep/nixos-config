{ config, lib, ... }:

{
  options.host = {
    containers.crowdsec = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Crowdsec container for this host";
      };
    };
  };

  config =
  let
    directory = "${config.users.users."${config.nixos.system.user.defaultuser.name}".home}/docker-containers/crowdsec";
  in lib.mkIf config.host.containers.crowdsec.enable
  {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/data 0755 ${config.nixos.system.user.defaultuser.name} users"
      "d ${directory}/config 0755 ${config.nixos.system.user.defaultuser.name} users"
    ];

    virtualisation.oci-containers.containers.crowdsec = {
      image = "ghcr.io/crowdsecurity/crowdsec";
      volumes = [
        "/var/log:/var/log:ro"
        "${directory}/data:/var/lib/crowdsec/data"
        "${directory}/config:/etc/crowdsec"
      ];
      networks = [ "caddy-bridge" ];
      hostname = "${config.networking.hostName}-crowdsec";
      environment = {
        TZ = "Europe/Paris";
      };
    };
  };
}