{ config, lib, ... }:

{
  options.homeManager.home = {
    accounts.greep-gmail = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable greep Gmail account.";
      };
    };
  };

  config = lib.mkIf config.homeManager.home.accounts.greep-gmail.enable {
    accounts.email.accounts.greep-gmail = {
      realName = "Greep";
      address = "89matt89.md@gmail.com";
      userName = "89matt89.md";
      imap = {
        host = "imap.gmail.com";
        port = 993;
      };
      smtp = {
        host = "smtp.gmail.com";
        port = 465;
      };
      thunderbird = lib.mkIf config.homeManager.applications.communication.thunderbird.enable {
        enable = true;
      };
    };
  };
}