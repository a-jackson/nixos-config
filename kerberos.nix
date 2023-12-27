{ ... }:
{
  imports = [
    ./base.nix
    ./de.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  services = {
    restic_backups = {
      daily = {
        paths = [
          "/persist"
          "/home"
        ];
        repo_key = "restic_kerberos_repo";
      };
    };
  };
}
