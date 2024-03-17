{ ... }: {
  imports = [
    ./nixvim
    ./ephemeral-btrfs.nix
    ./mergerfs.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./ports.nix
    ./restic.nix
    ./ssh.nix
  ];
}
