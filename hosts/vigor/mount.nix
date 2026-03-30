_:

{

  swapDevices = [
    {
      device = "/swapfile";
      size = 10240;
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
