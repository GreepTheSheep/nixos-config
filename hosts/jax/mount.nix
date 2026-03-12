{ pkgs, config, ... }:

{

  fileSystems = {
    "/" =
      { device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@" "compress=zstd" ];
      };

    "/home" =
      { device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@home" "compress=zstd:2" ];
      };

    "/nix" =
      { device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@nix" "compress=zstd:2" ];
      };

    "/var/log" =
      { device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@log" "compress=zstd:6" ];
      };

    "/boot" =
      { device = "/dev/disk/by-uuid/B88F-9482";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    "/mnt/DATA" =
      {
        device = "/dev/disk/by-uuid/A8B6592DB658FCEE";
        fsType = "ntfs";
      };
  };

  sops.secrets."bitlocker/windows-drive-password" = {};

  systemd.services."mnt-Windows" = {
    description = "Mount BitLocker encrypted NTFS /mnt/Windows";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "/dev/disk/by-uuid/6e2f4d75-a462-402e-a422-f8a3c82584ce";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "mount-windows" ''
        ${pkgs.cryptsetup}/bin/cryptsetup open --type bitlk \
          /dev/disk/by-uuid/6e2f4d75-a462-402e-a422-f8a3c82584ce \
          cryptwindows \
          --key-file ${config.sops.secrets."bitlocker/windows-drive-password".path}
        mkdir -p /mnt/Windows
        ${pkgs.ntfs3g}/bin/ntfs-3g /dev/mapper/cryptwindows /mnt/Windows
      '';
      ExecStop = pkgs.writeShellScript "umount-windows" ''
        umount /mnt/Windows || true
        ${pkgs.cryptsetup}/bin/cryptsetup close cryptwindows || true
      '';
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32768;
      priority = 10;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Hibernation — après install, récupérer l'offset avec:
  # sudo btrfs inspect-internal map-swapfile -r /swapfile
  boot.resumeDevice = "/dev/disk/by-uuid/6fa07085-ca6f-4d6a-8d60-5dddb94d2d4e";
  boot.kernelParams = [ "resume_offset=12854528" ];
}