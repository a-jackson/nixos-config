{ pkgs, ... }:
{
  programs = {
    gnupg.agent = {
      enable = true;
    };
  };

  users.users.andrew = {
    packages = with pkgs; [
      sops
      nixpkgs-fmt
    ];
  };
}
