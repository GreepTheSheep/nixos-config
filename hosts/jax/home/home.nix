_:

{
  homeManager = {
    applications = {
      enable = true;

      sync.deskflow.enable = true;

      development = {
        antigravity.enable = true;
        claudecode.enable = true;
        diff.enable = true;
        opencode.enable = true;
      };

      editing.video.enableDavinciResolve = true;

      wallpaperengine = {
        enable = true;
        wallpapers = [
          {
            wallpaperId = "3031397203";
            monitor = "DP-4";
          }
        ];
      };
    };

    base.tools.btop.enableGPUSupport = true;
  };
}