_:

{
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["greep"];
  users.users.greep.extraGroups = [ "libvirtd" ];

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}