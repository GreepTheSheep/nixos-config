{ config, pkgs, ... }:

{
  services.davfs2.enable = true;
  environment.systemPackages = [ pkgs.davfs2 ];

  environment.etc."davfs2/secrets".source = config.sops.templates."davfs2-secrets".path;

  sops.templates."davfs2-secrets" = {
    content = ''
      https://cloud.greep.fr/remote.php/webdav/ greep ${config.sops.placeholder."nextcloud/password"}
    '';
    mode = "0600";
  };

  fileSystems."/mnt/cloud" = {
    device = "https://cloud.greep.fr/remote.php/webdav/";
    fsType = "davfs";
    options = [ "rw" "uid=1000" "gid=1000" "_netdev" "auto" ];
  };
}