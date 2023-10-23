{ pkgs, ... }:
{
  imports = [
    ./common/shell.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
