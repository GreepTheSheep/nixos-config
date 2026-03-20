_:

{
  networking = {
    hostName = "varian";
  };

  nixos.system.firewall.extraAllowedTCPPorts = [
    8123  # Home Assistant
    # TODO: ajouter les ports des autres conteneurs
  ];
}
