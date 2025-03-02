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
      "ntfy/url" = { };
      "ntfy/token" = { };
    };

    homelab.notifications.sendNotification =
      let
        urlPath = config.sops.secrets."ntfy/url".path;
        tokenPath = config.sops.secrets."ntfy/token".path;
      in
      pkgs.writeShellScript "sendNotification" ''
        priority="2"
        contentType="text/plain"
        url=$(cat "${urlPath}")
        token=$(cat "${tokenPath}")
        tags=""

        while true; do
          case "$1" in
            --title) title="$2"; shift 2;;
            --message) message="$2"; shift 2;;
            --priority) priority="$2"; shift 2;;
            --markdown) contentType="text/markdown"; shift;;
            --tags) tags="$2"; shift 2;;
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


        ${pkgs.curl}/bin/curl \
          -H "Authorization: Bearer ''${token}" \
          -H "Title: ''${title}" \
          -H "Priority: ''${priority}" \
          -H "Content-Type: ''${contentType}" \
          -H "Tags: ''${tags}" \
          -d "''${message}" \
          "''${url}"
      '';
  };
}
