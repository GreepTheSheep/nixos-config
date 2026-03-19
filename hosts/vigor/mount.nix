_:

{

  swapDevices = [
    {
      device = "/swapfile";
      size = 6144;
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
