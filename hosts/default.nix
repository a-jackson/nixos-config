{ hostname, desktop, lib, ... }: {
  imports = [ ./common ./${hostname} ]
    ++ lib.optionals (desktop != null) [ ./common/${desktop} ];

  networking.hostName = hostname;
}
