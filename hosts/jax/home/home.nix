_:

{
  homeManager = {
    applications = {
      enable = true;

      communication.mumble.enableTMLink = true;

      sync.deskflow.enable = true;

      development = {
        claudecode.enable = true;
        diff.enable = true;
        opencode.enable = true;
      };

      media.feishin.useUnstable = true;

      gaming = {
        bs-manager.enable = true;
        nxapi = {
          enable = true;
          enableElectronApp = true;
        };
      };

      utils.rpi-imager.enable = true;

      wallpaperengine = {
        enable = true;
        wallpapers = [
          {
            wallpaperId = "3386113945";
            monitor = "auto";
            properties = {
              showclock = false;
              showdate = false;
              showday = false;
            };
          }
        ];
      };
    };

    base.tools.btop.enableGPUSupport = true;
  };
}
