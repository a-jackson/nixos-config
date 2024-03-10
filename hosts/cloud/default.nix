{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../common
  ];
  ephemeral-btrs = false;
  homelab = {
    impermanence.enable = false;
    systemd-boot = false;
    sops.keyPath = "/etc/ssh/ssh_host_ed25519_key";
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBndztf9Vpi3WeAlu/WEVVkF8TaNo1sCSwRsYLCNML2a'' ];
}
