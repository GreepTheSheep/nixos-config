{ config, lib, ... }:


let
  heliumPolicies = builtins.toJSON {
    MetricsReportingEnabled = false;
    BlockThirdPartyCookies = true;
    HardwareAccelerationModeEnabled = true;
    DnsOverHttpsMode = "secure";
    DnsOverHttpsTemplates = "https://cloudflare-dns.com/dns-query";
    PasswordManagerEnabled = false; # Overridden by Bitwarden
    VideoCaptureAllowed = false;
    DefaultGeolocationSetting = 2;
    DefaultNotificationsSetting = 2;
    PromptForDownloadLocation = true;

    # Extensions
    #ExtensionInstallAllowlist = ["*"];
    #ExtensionInstallForcelist = [
      #"nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden Password Manager
      #"mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx" # SponsorBlock
      #"gebbhagfogifgggkldgodflihgfeippi;https://clients2.google.com/service/update2/crx" # Return YouTube Dislikes
      #"hnmpcagpplmpfojmgmnngilcnanddlhb;https://clients2.google.com/service/update2/crx" # Windscribe VPN
      #"nlkaejimjacpillmajjnopmpbkbnocid;https://clients2.google.com/service/update2/crx" # Youtube Non-Stop
      #"ndpmhjnlfkgfalaieeneneenijondgag;https://clients2.google.com/service/update2/crx" # Youtube Anti-Translate
      #"ammjkodgmmoknidbanneddgankgfejfh;https://clients2.google.com/service/update2/crx" # 7TV
    #];
  };
in
{
  options.nixos = {
    userEnvironment.config.helium-policies = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Helium Policies";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.config.helium-policies.enable {
    environment.etc."chromium/policies/managed/helium.json".text = heliumPolicies;
  };
}