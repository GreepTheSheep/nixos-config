{ lib, ... }:

{
  homeManager = {
    applications.enable = false;
    base.tools.btop.enableGPUSupport = true;
  };
}