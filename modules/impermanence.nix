{
  impermanence,
  config,
  lib,
  ...
}:
{
  imports = [ impermanence.nixosModules.impermanence ];

  options.homelab = with lib; {
    impermanence.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.homelab.impermanence.enable {

    environment = {
      persistence."/persist" = {
        directories = [
          "/etc/ssh"
          "/var/lib"
          "/var/log"
          "/var/db/sudo/lectured"
          "/etc/NetworkManager"
        ];
        files = [
          "/etc/machine_id"
          "/etc/nix/id_rsa"
        ];
      };
    };
  };
}
