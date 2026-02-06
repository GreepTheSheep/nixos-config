_:

{
  programs.firefox = {
    enable = true;
    languagePacks = [ "fr" "en-US" ];
    policies = {
      HardwareAcceleration = true;
      BlockAboutConfig = true;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisplayBookmarksToolbar = "always";
      DisplayMenuBar = "default-off";
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "cloudflare-dns.com";
        Locked = true;
        Fallback = true;
      };
      SearchBar = "unified";
      FirefoxHome = {
        Highlights = false;
        Pocket = false;
        Search = true;
        Snippets = false;
        TopSites = false;
      };
      Homepage = {
        Additional = [];
        StartPage = "home";
      };
      NewTabPage = true;
      OfferToSaveLogins = false; # Overridden by Bitwarden
      OfferToSaveLoginsDefault = false;
      Permissions = {
        Camera.BlockNewRequests = true;
        Location.BlockNewRequests = true;
        Notifications.BlockNewRequests = true;
      };
      Preferences = {
        "browser.tabs.warnOnClose" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.openpage" = true;
        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "extensions.getAddons.showPane" = true;
        "places.history.enabled" = false;
        "ui.key.menuAccessKeyFocuses" = false;
      };
      PromptForDownloadLocation = true;
      SanitizeOnShutdown = {
        Cache = true;
      };

      ExtensionSettings = {
        "*".installation_mode = "allowed";

        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # Bitwarden Password Manager
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # Sponsorblock
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # Windscribe Proxy
        "@windscribeff" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/windscribe/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # Adaptive Tab Bar Colour
        "ATBC@EasonWong" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/adaptive-tab-bar-colour/latest.xpi";
          installation_mode = "force_installed";
        };

        # Youtube Non-Stop
        "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
          installation_mode = "force_installed";
        };

        # Return Youtube Dislikes
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
          installation_mode = "force_installed";
        };

        # Youtube Anti Translate
        "{458160b9-32eb-4f4c-87d1-89ad3bdeb9dc}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-anti-translate/latest.xpi";
          installation_mode = "force_installed";
        };

        # 7TV
        "moz-addon-prod@7tv.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/7tv-extension/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}