{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.browser.helium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable Helium browser.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.browser.helium.enable (
    let
      helium = pkgs.nur.repos.lonerOrz.helium;

      # WebGPU materiel = Dawn/Vulkan. Sous Wayland, Chromium ne supporte pas
      # Vulkan (cf. wayland_surface_factory.cc), d'ou le passage en XWayland.
      # Fermer Helium avant de lancer cette entree, sinon le single-instance
      # absorbe la commande et ignore les flags.
      heliumXwaylandVulkan = pkgs.writeShellScriptBin "helium-xwayland-vulkan" ''
        exec ${helium}/bin/helium \
          --ozone-platform=x11 \
          --enable-features=Vulkan \
          "$@"
      '';

      mimeTypes = [
        "application/pdf"
        "application/rdf+xml"
        "application/rss+xml"
        "application/xhtml+xml"
        "application/xhtml_xml"
        "application/xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/webp"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    in
    {
      home.packages = [
        helium
        heliumXwaylandVulkan
      ];

      # Entree de menu separee : Helium par defaut reste en Wayland natif,
      # celle-ci sert uniquement aux applis 3D necessitant le WebGPU materiel.
      xdg.desktopEntries."helium-xwayland-vulkan" = {
        name = "Helium (XWayland + Vulkan)";
        comment = "Helium en XWayland avec Vulkan pour le WebGPU materiel. Fermer Helium avant de lancer.";
        genericName = "Web Browser";
        exec = "${heliumXwaylandVulkan}/bin/helium-xwayland-vulkan %U";
        icon = "helium";
        startupNotify = true;
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = mimeTypes;
        settings = {
          StartupWMClass = "helium";
          Keywords = "helium;web browser;webgpu;vulkan";
        };
        actions = {
          new-window = {
            name = "New Window";
            exec = "${heliumXwaylandVulkan}/bin/helium-xwayland-vulkan %U";
          };
          new-private-window = {
            name = "New Incognito Window";
            exec = "${heliumXwaylandVulkan}/bin/helium-xwayland-vulkan --incognito %U";
          };
        };
      };
    }
  );
}
