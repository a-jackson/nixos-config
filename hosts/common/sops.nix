{
  sops-nix,
  lib,
  config,
  ...
}:
{
  imports = [ sops-nix.nixosModules.sops ];

  options = {
    homelab.sops.keyPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist/etc/ssh/ssh_host_ed25519_key";
    };
  };

  config = {
    sops = {
      age.sshKeyPaths = [ config.homelab.sops.keyPath ];
      gnupg.sshKeyPaths = [ ];
      defaultSopsFile = ../../secrets/common.yaml;
    };
  };
}
