_:

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
    ExtensionSettings = {
      "*".installation_mode = "allowed";

      # Bitwarden Password Manager
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # SponsorBlock
      "mnjggcdmjocbbbhaepdhchncahnbgone" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # Return YouTube Dislikes
      "gebbhagfogifgggkldgodflihgfeippi" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # Windscribe VPN
      "hnmpcagpplmpfojmgmnngilcnanddlhb" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # Youtube Non-Stop
      "nlkaejimjacpillmajjnopmpbkbnocid" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # Youtube Anti-Translate
      "ndpmhjnlfkgfalaieeneneenijondgag" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };

      # 7TV
      "ammjkodgmmoknidbanneddgankgfejfh" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };

    ExtensionInstallForcelist = [
      "nngceckbapebfimnlniiiahkandclblb"
      "mnjggcdmjocbbbhaepdhchncahnbgone"
      "gebbhagfogifgggkldgodflihgfeippi"
      "hnmpcagpplmpfojmgmnngilcnanddlhb"
      "nlkaejimjacpillmajjnopmpbkbnocid"
      "ndpmhjnlfkgfalaieeneneenijondgag"
      "ammjkodgmmoknidbanneddgankgfejfh"
    ];
  };
in
{
  environment.etc."chromium/policies/managed/helium.json".text = heliumPolicies;
}
