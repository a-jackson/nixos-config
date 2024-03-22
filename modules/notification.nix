{ config, lib, pkgs, ... }: {
  options.homelab.notifications = {
    sendNotification = lib.mkOption { type = lib.types.package; };
  };

  config = {
    sops.secrets = {
      "gotify/url" = { };
      "gotify/token" = { };
    };

    homelab.notifications.sendNotification = let
      urlPath = config.sops.secrets."gotify/url".path;
      tokenPath = config.sops.secrets."gotify/token".path;
    in pkgs.writeShellScript "sendNotification" ''
      title="$1"
      message="$2"
      priority="''${3:-4}"
      url=$(cat "${urlPath}")
      token=$(cat "${tokenPath}")

      ${pkgs.gotify-cli}/bin/gotify push \
        --url "''${url}" \
        --token "''${token}" \
        --title "''${title}" \
        --priority "''${priority}" \
        "''${message}"
    '';
  };
}
