{ config, lib, ... }:

{
  imports = [
    ./discord.nix
  ];

  options.host = {
    hermes-agent.messaging = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Hermes Agent to messaging platforms";
      };
    };
  };

  config = lib.mkIf config.host.hermes-agent.messaging.enable {
    host.hermes-agent.messaging = {
      discord.enable = true;
    };
  };
}
