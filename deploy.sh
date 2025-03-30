#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#nixos-rebuild --command bash

cmd="${1-switch}"

sudo nixos-rebuild "$cmd" --flake ".#$(hostname)"
