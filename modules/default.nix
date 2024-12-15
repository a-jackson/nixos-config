{ lib, ... }:
{
  imports = [
    ./nixvim
    ./dns.nix
    ./ephemeral-btrfs.nix
    ./impermanence.nix
    ./monitoring.nix
    ./notification.nix
    ./ports.nix
    ./restic.nix
    ./ssh.nix
    ./syncthing.nix
  ];

  options.homelab.homeType = lib.mkOption {
    type = lib.types.str;
    default = "headless";
  };
}
