{ config, lib, pkgs, ... }:

{
  options.nixos = {
    server.vscode-server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable VSCode Server.";
      };

      external = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Set VSCode Server to be used externally.";
      };
    };
  };

  config = lib.mkIf config.nixos.server.vscode-server.enable {
    services.code-server = {
      enable = true;
      disableTelemetry = true;
      disableUpdateCheck = true; # Managed by Nix
      disableGettingStartedOverride = true;
      extraGroups = lib.mkIf config.nixos.virtualisation.docker.enable [ "docker" ]; # Enable docker integration
      user = config.nixos.system.user.defaultuser.name;
      group = "users";
      host = lib.mkIf config.nixos.server.vscode-server.external "0.0.0.0";
      hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$RFNsY1dEdDhsNlFlNzFHRVFUNDVZTmtjdHNFPQ$17l6TCDlqDPOZU36F53bq6+Cx3JStknR1jhj+3DBQu8";
    };

    nixos.system.firewall.extraAllowedTCPPorts = lib.mkIf config.nixos.server.vscode-server.external [ 4444 ];
  };
}