{ config, lib, pkgs, spicetify-nix, inputs, ... }:

{
  imports = [
    spicetify-nix.nixosModules.spicetify
  ];

  options.nixos = {
    userEnvironment.spotify = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable spicetify client.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.spotify.enable {
    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        beautifulLyrics
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      theme = spicePkgs.themes.sleek;
      colorScheme = "Deep";
      enabledCustomApps = with spicePkgs.apps; [
        marketplace
        newReleases
        ncsVisualizer
      ];
    };

    environment.defaultPackages = with pkgs; [
      spotifywm
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
  };
}