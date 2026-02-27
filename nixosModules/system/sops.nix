{
  config,
  lib,
  pkgs,
  sops-nix,
  ...
}:

{
  imports = [
    sops-nix.nixosModules.sops
  ];

  options.nixos = {
    system.sops = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Sops.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.sops.enable {
    #systemd.services.webdav.serviceConfig.EnvironmentFile = [
    #  config.sops.secrets.changeme_env.path
    #];

    environment.systemPackages = with pkgs; [
      sops
    ];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.keyFile = lib.mkDefault "/secrets/keys.txt";

      secrets = {
        "nextcloud/password" = {};
      };
    };
  };
}