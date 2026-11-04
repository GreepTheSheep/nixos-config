{ config, lib, ... }:

{
  options.host = {
    hermes-agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Hermes Agent config for this host";
      };
    };
  };

  config = lib.mkIf config.host.hermes-agent.enable {
    nixos.userEnvironment.hermes-agent.enable = true;

    services.hermes-agent.settings = {
      webapp = {
        enabled = true;
      };
    };
  };
}
