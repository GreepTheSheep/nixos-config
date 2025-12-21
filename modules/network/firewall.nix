_:

{
  networking.firewall = {
    allowedTCPPorts = [
      22 # SSH
      3389 # RDP
    ];
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];

    allowedUDPPorts = [
      22 # SSH
      3389 # RDP
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };
}