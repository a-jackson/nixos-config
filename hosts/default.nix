{
  hostname,
  desktop,
  lib,
  ...
}:
{
  imports = [
    ./common
    ./${hostname}
    ./common/hyprland
  ] ++ lib.optionals (desktop != null) [ ./common/${desktop} ];

  networking.hostName = hostname;
}
