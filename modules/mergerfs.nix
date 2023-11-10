{ pkgs, lib, config, ... }:
let
  overlay = final: prev: {
    mergerfs = prev.mergerfs.overrideAttrs (old: {
      version = "2.38.0";
      src = prev.fetchFromGitHub {
        owner = "trapexit";
        repo = "mergerfs";
        rev = "2.38.0";
        sha256 = "sha256-4WowGrmFDDpmZlAVH73oiKBdgQeqEkbwZCaDSd1rAEc=";
      };
    });
  };

  inherit (lib) mkOption mkEnableOption mkIf types;

  cfg = config.services.mergerfs;
in
{
  options.services.mergerfs = {
    enable = mkEnableOption ''
      mergerfs
    '';
    mountPoint = mkOption {
      type = types.str;
      default = "/mnt/storage";
    };
    disks = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable
    {
      nixpkgs.overlays = [ overlay ];

      environment.systemPackages = with pkgs; [
        mergerfs
      ];

      environment.etc.mergerfs = {
        text = ''
          cache.files=off
          moveonenospc=true
          category.create=mfs
          dropcacheonclose=true
          minfreespace=250G
          fsname=mergerfs
        '';
      };

      system.activationScripts.mergerfsMount = ''
        mkdir -p ${cfg.mountPoint}
      '';

      systemd.services.mergerfs = {
        description = "Mergerfs mount";

        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          # Provide select user for this service according to the needs
          User = "root";
          Restart = "on-failure";
          ExecStart = "${pkgs.mergerfs}/bin/mergerfs -f -o config=/etc/mergerfs ${lib.strings.concatStringsSep ":" cfg.disks} ${cfg.mountPoint}";
        };
      };
    };
}

# [Unit]
# Description=Dummy mergerfs service
# Requires=prepare-for-mergerfs.service
# After=prepare-for-mergerfs.service

# [Service]
# Type=simple
# KillMode=none
# ExecStart=/usr/bin/mergerfs \
#   -f \
#   -o OPTIONS \
#   /mnt/filesystem0:/mnt/filesystem1 \
#   /mnt/mergerfs
# ExecStop=/bin/fusermount -uz /mnt/mergerfs
# Restart=on-failure

# [Install]
# WantedBy=default.target
