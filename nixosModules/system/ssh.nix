{ config, lib, ... }:

{
  options.nixos = {
    system.ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable ssh with sshguard.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.ssh.enable {
    sops.secrets = {
      "ssh/authorizedKeys" = {};
      "ssh/rootAuthorizedKeys" = {};
    };
    sops.templates = {
      "ssh-authorizedKeys".content = ''
        ${config.sops.placeholder."ssh/authorizedKeys"}
      '';
      "ssh-rootAuthorizedKeys".content = ''
        ${config.sops.placeholder."ssh/rootAuthorizedKeys"}
      '';
    };

    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
        PrintMotd = true;
      };
    };

    services.sshguard = {
      enable = true;
      services = [ "sshd" ];
      whitelist = [
        "192.168.1.0"
      ];
      blocktime = 3600;
      detection_time = 30758400;
      blacklist_threshold = 60;
      attack_threshold = 10;
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [config.sops.templates."ssh-rootAuthorizedKeys".path];
    users.users."${config.nixos.system.user.defaultuser.name}".openssh.authorizedKeys.keyFiles = [config.sops.templates."ssh-authorizedKeys".path];
    nixos.system.firewall.extraAllowedTCPPorts = [ 22 ];
  };
}