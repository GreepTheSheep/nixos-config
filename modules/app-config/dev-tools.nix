{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    rustup
    nodejs_24
    bun
    python315
    virtualenv
  ];
}