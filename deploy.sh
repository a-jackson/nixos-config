#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash nixos-rebuild

hosts="$1"
shift

if [ -z "$hosts" ]; then
    sudo nixos-rebuild switch --flake ".#$(hostname)"
fi

for host in ${hosts//,/ }; do
    nixos-rebuild switch --flake ".#$host" --target-host "root@$host" --build-host "root@$host"
done
