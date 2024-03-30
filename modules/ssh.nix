{ username, ... }: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBndztf9Vpi3WeAlu/WEVVkF8TaNo1sCSwRsYLCNML2a andrew@laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAji09O1A1D5cgPamTsNboy0yI6xpkOJiw62qZnTJvE4 andrew@work"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhSjouruU6vkg0CD7vQJkswSrHyZoRUWSCtXOJQUWkP andrew@desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHl4O67pNR9qCLPIreConH9zCzuTYv+UTchslf/Y3S8 connectbot"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANUHQBNCx4OJRJpcxht+91Do/jUqg2PlX0Vezciu7/L termux"
  ];
}
