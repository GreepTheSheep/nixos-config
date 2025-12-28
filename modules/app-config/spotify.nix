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
    path = with pkgs; [ curl bash perl zip unzip coreutils procps util-linux sudo ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -sSL https://spotx-official.github.io/run.sh | ${pkgs.bash}/bin/bash -s -- -h'";
    };
  };

}