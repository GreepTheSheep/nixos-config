_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4bae51e2-a37a-4c2f-8e34-8bb62706b22d";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DF6D-8B80";
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
