{ config, lib, ... }:

{
  options.host = {
    containers.whoami = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WhoAmI container for this host";
      };
    };
  };

  config = lib.mkIf config.host.containers.whoami.enable
  {
    virtualisation.oci-containers.containers.whoami = {
      image = "traefik/whoami";
      ports = [
        "2026:2026"
      ];
      environment = {
        TZ = "Europe/Paris";
        WHOAMI_PORT_NUMBER = "2026";
        WHOAMI_NAME = "jax-toy";
      };
    };

    nixos.system.firewall.extraAllowedTCPPorts = [ 2026 ];
  };
}