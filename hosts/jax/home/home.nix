_:

{
  homeManager = {
    applications = {
      enable = true;

      sync.deskflow.enable = true;

      development = {
        claudecode.enable = true;
        diff.enable = true;
        opencode.enable = true;
      };

      editing.video.enableDavinciResolve = true;

      gaming.nxapi = {
        enable = true;
        enableElectronApp = true;
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