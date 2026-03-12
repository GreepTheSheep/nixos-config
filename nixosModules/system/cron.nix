{ config, lib, ... }:

{
  options.nixos = {
    system.cron = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable cron service.";
      };

      jobs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "0 * * * * crontab -l > /root/crontab-backup    # Note: this job is added automatically to the system in this cron.nix file"
        ];
        description = "A list of Cron jobs to be appended to the system-wide crontab.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.cron.enable {
    services.cron = {
      enable = true;

      systemCronJobs = [
        "0 * * * * crontab -l > /root/crontab-backup"
      ] ++ config.nixos.system.cron.jobs;
    };
  };
}