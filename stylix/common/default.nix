{ lib, ... }:
{
  stylix.targets.tmux.enable = lib.mkForce false;
  stylix.targets.fish.enable = lib.mkForce true;
}
