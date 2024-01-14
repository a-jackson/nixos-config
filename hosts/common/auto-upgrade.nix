{ config, self, pkgs, lib, ... }:
let
  inherit (config.networking) hostName;
  # Only enable auto upgrade if current config came from a clean tree
  # This avoids accidental auto-upgrades when working locally.
  isClean = self ? rev;
in
{
  system.autoUpgrade = {
    enable = isClean;
    dates = "hourly";
    flags = [
      "--refresh"
    ];
    flake = "github:a-jackson/nixos-config?ref=master";
  };
}