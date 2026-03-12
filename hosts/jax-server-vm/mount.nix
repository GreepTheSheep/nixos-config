_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/63dc0d8b-897d-4ce1-a964-bab9cfdc006f";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3B09-B28E";
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
}
