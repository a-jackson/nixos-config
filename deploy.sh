#!/usr/bin/env bash
export NIX_SSHOPTS="-At"

hosts="$1"
shift

if [ -z "$hosts" ]; then
    sudo nixos-rebuild switch --flake ".#$(hostname)"
fi

for host in ${hosts//,/ }; do
    nixos-rebuild --flake ".#$host" switch --target-host "root@$host" --build-host "root@$host" "$@"
done
