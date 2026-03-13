{ config, lib, ... }:

{
  options.nixos = {
    base.tools.scrutiny = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable scrutiny.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.scrutiny.enable {
    services.scrutiny = {
      enable = true;
      openFirewall = true;

      settings = {
        web = {
          listen.port = 9899;
        };
      };
    };

    nixos.system.firewall.extraAllowedTCPPorts = [ 9899 ];

    # Create a host to redirect http://scrutiny/ to the scrutiny service
    networking.hosts = {
      "127.0.0.1" = lib.mkAfter [ "scrutiny" "scrutiny.local" ];
    };
  };
}