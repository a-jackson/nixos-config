{
  hostname,
  desktop,
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
}
