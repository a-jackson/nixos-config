{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.notifications = {
    sendNotification = lib.mkOption { type = lib.types.package; };
  };

  config = {
    sops.secrets = {
      "gotify/url" = { };
      "gotify/token" = { };
    };

    homelab.notifications.sendNotification =
      let
        urlPath = config.sops.secrets."gotify/url".path;
        tokenPath = config.sops.secrets."gotify/token".path;
      in
      pkgs.writeShellScript "sendNotification" ''
        priority="4"
        contentType="text/plain"
        url=$(cat "${urlPath}")
        token=$(cat "${tokenPath}")

        while true; do
          case "$1" in
            --title) title="$2"; shift 2;;
            --message) message="$2"; shift 2;;
            --priority) priority="$2"; shift 2;;
            --markdown) contentType="text/markdown"; shift;;
            *) break;
          esac
        done

        if [ -z "$title" ]; then
          echo "--title required"
          exit 1
        fi

        if [ -z "$message" ]; then
          echo "--message required"
          exit 1
        fi


        ${pkgs.gotify-cli}/bin/gotify push \
          --url "''${url}" \
          --token "''${token}" \
          --title "''${title}" \
          --priority "''${priority}" \
          --contentType "''${contentType}" \
          "''${message}"
      '';
  };
}
