{ lib, ... }:

{
  homeManager.applications = {
    # Bundle complet coupé sur le Pi (pas de bureau) : on n'active qu'Helium.
    enable = false;

    browser.helium.enable = true;
  };
}