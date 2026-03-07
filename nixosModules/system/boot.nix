{ config, lib, pkgs, ... }:

{
  options.nixos = {
    system.boot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Set boot options.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.boot.enable {
    boot.initrd.availableKernelModules = [ "sr_mod" ];
    boot.kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "udev.log-priority=3"
      "vt.global_cursor_default=1"
    ];
    boot.kernelModules = [ "fuse" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [
      "ntfs"
    ];

    boot.initrd.systemd.enable = true;

    boot.plymouth.enable = true;

    services.fwupd.enable = true;

    security.polkit.enable = true; # login for actions without root

    services.acpid.enable = true;

    services.udisks2.enable = true; # power managment events

    boot.initrd.systemd.services.numlock = {
      description = "Enable NumLock on TTYs";

      wantedBy = [ "initrd.target" ];
      after = [ "systemd-vconsole-setup.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        for tty in /dev/tty{1..6}; do
          ${pkgs.kbd}/bin/setleds -D +num < $tty
        done
      '';
    };
  };
}