{ config, lib, ... }:

{
  imports = [
    ./shell
    ./texteditor
    ./tools
  ];

  options.nixos = {
    base.caddy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Enable caddy web server. It will be used for local web services only, it is not meant to be exposed to the internet.
          The docker caddy image should be used to expose services to the internet.
        '';
      };
    };
  };

  config = lib.mkIf config.nixos.base.caddy.enable {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "backrest.local" = lib.mkIf config.nixos.base.tools.backrest.enable {
          extraConfig = ''
            reverse_proxy localhost:9898
            tls internal
          '';
        };
        "scrutiny.local" = lib.mkIf config.nixos.base.tools.scrutiny.enable {
          extraConfig = ''
            reverse_proxy localhost:9899
            tls internal
          '';
        };
      };
    };
  };
}