#!/usr/bin/env bash
export NIX_SSHOPTS="-A"

build_remote=false

hosts="$1"
shift

if [ -z "$hosts" ]; then
    sudo nixos-rebuild switch --flake .#$(hostname)
fi

for host in ${hosts//,/ }; do
    nixos-rebuild --flake .\#$host switch --target-host $host --use-remote-sudo --use-substitutes $@
done
