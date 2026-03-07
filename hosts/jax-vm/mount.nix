_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1153cd46-0b8c-4017-8383-fd99132dd4f5";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C886-7B81";
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
  #boot.resumeDevice = "/dev/disk/by-uuid/1153cd46-0b8c-4017-8383-fd99132dd4f5";
  #boot.kernelParams = [ "resume_offset=XXXXXXXX" ];
}