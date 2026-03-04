_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1204b7ab-1366-46c5-8989-be545186b3b5";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C1F9-4D48";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
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
  boot.resumeDevice = "/dev/disk/by-uuid/1204b7ab-1366-46c5-8989-be545186b3b5";
  boot.kernelParams = [ "resume_offset=XXXXXXXX" ];
}