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

  config =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
    in lib.mkIf config.nixos.userEnvironment.spotify.enable {
    programs.spicetify = {
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
  };
}