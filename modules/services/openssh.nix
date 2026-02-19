_:

{
  services.openssh = {
    enable = true;
    knownHosts = {
      vigor = {
        extraHostNames = [
          "192.168.1.55"
          "vigor.greep.fr"
        ];
        #publicKey = ""; # Clé a regénerer plus tard
      };

      rapunzel = {
        extraHostNames = [
          "rapunzel.greep.fr"
        ];
        #publicKey = ""; # Clé a regénerer plus tard
      };

      billcipher = {
        extraHostNames = [
          "billcipher.greep.fr"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+0wHYr4s3EN5a2jrYeKd80GP3JINFIAC/DbK9FeCb6 root@billcipher.greep.fr";
      };

    };
  };
}