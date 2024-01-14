{ config, lib, ... }: {
  options = { };

  config = lib.mkIf config.services.tailscale.enable {
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/tailscale"
      ];
    };
  };
}
