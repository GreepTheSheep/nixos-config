_:

let
  heliumPolicies = builtins.toJSON {
    # Telemetrie et vie privee
    MetricsReportingEnabled = false;
    BlockThirdPartyCookies = true;

    # Acceleration materielle
    HardwareAccelerationModeEnabled = true;

    # DNS-over-HTTPS (Cloudflare)
    DnsOverHttpsMode = "secure";
    DnsOverHttpsTemplates = "https://cloudflare-dns.com/dns-query";

    # Gestionnaire de mots de passe desactive (Bitwarden utilise)
    PasswordManagerEnabled = false;

    # Bloquer les demandes de permissions
    VideoCaptureAllowed = false;
    DefaultGeolocationSetting = 2;
    DefaultNotificationsSetting = 2;

    # Telechargements
    PromptForDownloadLocation = true;

    # Interface
    BookmarkBarEnabled = true;
    RestoreOnStartup = 1;

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
      "gebbhagfogifgklhldnoajcejolblihc" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };
in
{
  environment.etc."chromium/policies/managed/helium.json".text = heliumPolicies;
}
