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

      editing.video.enableDavinciResolve = true;

      gaming = {
        bs-manager.enable = true;
        dolphin-emu.enable = true;
        nxapi = {
          enable = true;
          enableElectronApp = true;
        };
        wheelwizard.enable = true;
      };

      wallpaperengine = {
        enable = true;
        wallpapers = [
          {
            wallpaperId = "3295216327";
            monitor = "auto";
          }
        ];
      };
    };

    base.tools.btop.enableGPUSupport = true;
  };
}
