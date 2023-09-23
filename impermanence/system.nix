{ impermanence, ... }:
{
  imports = [
    impermanence.nixosModules.impermanence
  ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/ssh"
      "/var/log"
      "/var/db/sudo/lectured"
      "/etc/NetworkManager"
    ];
    files = [
      "/etc/machine_id"
      "/etc/nix/id_rsa"
      "/var/lib/logrotate.status"
    ];
  };
}
