{ config, lib, ... }:

{
  options.homeManager.home = {
    accounts.greep = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable greep account.";
      };
    };
  };

  config = lib.mkIf config.homeManager.home.accounts.greep.enable {
    accounts.email.accounts.greep = {
      name = "Greep";
      realName = "Greep";
      address = "greep@greep.fr";
      imap = {
        host = "billcipher.greep.fr";
        port = 993;
      };
      smtp = {
        host = "billcipher.greep.fr";
        port = 465;
      };
      thunderbird = lib.mkIf config.homeManager.applications.communication.thunderbird.enable {
        enable = true;
      };
    };
  };
}