{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users."andrew".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBndztf9Vpi3WeAlu/WEVVkF8TaNo1sCSwRsYLCNML2a"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHm89r7LAm2AlRpOixjeLpgK33HFvNyQEEwyKf8p/D10"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAji09O1A1D5cgPamTsNboy0yI6xpkOJiw62qZnTJvE4"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHl4O67pNR9qCLPIreConH9zCzuTYv+UTchslf/Y3S8"
  ];
}
