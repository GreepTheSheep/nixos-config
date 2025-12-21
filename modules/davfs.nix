{ config, pkgs, ... }:

{
  services.davfs2.enable = true;
  environment.systemPackages = [ pkgs.davfs2 ];

  environment.etc."davfs2/secrets" = {
    text = ''
      https://cloud.greep.fr/remote.php/webdav/ greep ${config.sops.secrets."nextcloud/password"}
    '';
    mode = "0600";
  };

  fileSystems."/mnt/cloud" = {
    device = "https://nextcloud.example.com/remote.php/webdav/";
    fsType = "davfs";
    options = [ "rw" "uid=1000" "gid=1000" "_netdev" "auto" ];
  };
}