{ sops-nix, ... }:
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };
}
