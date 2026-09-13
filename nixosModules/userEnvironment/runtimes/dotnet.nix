{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos = {
    userEnvironment.runtimes.dotnet = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable .NET SDK";
      };

      version = lib.mkOption {
        type = lib.types.ints.between 6 11;
        default = 10;
        description = "The choosen version of .NET SDK.";
      };
    };
  };

  config =
    let
      version = config.nixos.userEnvironment.runtimes.dotnet.version;
      dotnetPackage = pkgs."dotnet-sdk_${builtins.toString version}";
    in
    lib.mkIf config.nixos.userEnvironment.runtimes.dotnet.enable {
      environment.systemPackages = [
        dotnetPackage
      ];
    };
}
