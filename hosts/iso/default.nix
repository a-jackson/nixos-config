{ lib, username, ... }:
let
  passwordHash =
    "$y$j9T$F3gDRp8hGFlKlY7PgHPSf0$LIHQ8VsP4rbc.Xig.ZgixugUwl.zS8l4/A.LkiLH680";
in {
  networking.useDHCP = lib.mkDefault true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  homelab = { impermanence.enable = false; };
  ephemeral-btrs = false;

  users.users = {
    ${username} = {
      hashedPassword = passwordHash;
      hashedPasswordFile = lib.mkForce null;
    };
    root = {
      hashedPassword = passwordHash;
      hashedPasswordFile = lib.mkForce null;
    };
  };

  # Allow passworded ssh
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkForce true;
    };
  };
}
