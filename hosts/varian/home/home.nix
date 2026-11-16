{ lib, ... }:

{
  # Hôte headless : aucune application desktop n'est installée.
  homeManager.applications.enable = false;
}
