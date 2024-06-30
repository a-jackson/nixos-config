{
  hostname,
  desktop,
  homeType,
  lib,
  ...
}:
{
  imports =
    [
      ./common
      ./${hostname}
    ]
    ++ lib.optionals (desktop != null) [
      ./common/${desktop}
      ./common/desktop.nix
    ];

  networking.hostName = hostname;
  homelab.homeType =
    if homeType != null then
      homeType
    else if desktop != null then
      desktop
    else
      "headless";
}
