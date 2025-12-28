{ pkgs, ... }:

{
  environment.defaultPackages = with pkgs; [
    spotify
    spotifywm
    spicetify-cli
  ];

  systemd.services.spotx-setup = {
    description = "Run SpotX installation";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -sSL https://spotx-official.github.io/run.sh | ${pkgs.bash}/bin/bash -h'";
    };
  };

}