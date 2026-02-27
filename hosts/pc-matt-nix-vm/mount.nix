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

  swapDevices = [ { device = "/dev/disk/by-uuid/775d86e7-3e78-4a20-896b-44ff838e8170"; } ];
}