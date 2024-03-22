{ ... }: {
  imports = [
    ./nixvim
    ./ephemeral-btrfs.nix
    ./mergerfs.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./notification.nix
    ./ports.nix
    ./restic.nix
    ./ssh.nix
  ];
}
