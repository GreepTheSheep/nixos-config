{ lib, ... }:

{
  system.stateVersion = "25.11";
  networking.hostName = "greep-nixos-live-iso";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Disable sops secrets for the live ISO (no SSH host keys available)
  sops = {
    age.sshKeyPaths = lib.mkForce [];
    secrets = lib.mkForce {};
    templates = lib.mkForce {};
  };
}
