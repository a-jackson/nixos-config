{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBndztf9Vpi3WeAlu/WEVVkF8TaNo1sCSwRsYLCNML2a'' ];
  system.stateVersion = "23.11";
}