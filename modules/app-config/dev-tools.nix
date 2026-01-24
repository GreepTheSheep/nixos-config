{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    rustup
    nodejs_24
    python315
    virtualenv
  ];
}