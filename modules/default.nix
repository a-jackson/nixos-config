{ lib, ... }: {
  imports = [
    ./nixvim
    ./ephemeral-btrfs.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./notification.nix
    ./ports.nix
    ./restic.nix
    ./ssh.nix
  ];

  options.homelab.homeType = lib.mkOption {
    type = lib.types.str;
    default = "headless";
  };
}
