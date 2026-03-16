_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c77642a3-22d0-4f61-8afc-fe0bf506b035";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F17A-374A";
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
