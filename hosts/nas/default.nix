{
  username,
  pkgs,
  config,
  ...
}:
let
  backupPaths = [
    "/persist"
    "/home"
    "/mnt/user"
  ];
  excludePaths = [
    "/mnt/user/audio"
    "/mnt/user/software"
    "/mnt/user/video/films"
    "/mnt/user/video/f1"
    "/mnt/user/video/tv"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    # ./containers.nix
    ./disks.nix
    ./networking.nix
    ./nfs.nix
  ];

  homelab = {
    root = {
      ephemeralBtrfs.enable = true;
    };
    impermanence.enable = true;
    monitoring.enable = true;
    restic = {
      daily = {
        paths = backupPaths;
        exclude = excludePaths;
      };
    };

    dns = {
      enable = true;
      virtualHosts.target = "192.168.1.205";
    };
  };

  fileSystems."/mnt/parity" = {
    device = "/dev/disk/by-label/parity";
    fsType = "xfs";
  };

  services = {
    snapraid = {
      enable = true;
      parityFiles = [ "/mnt/parity/snapraid.parity" ];
      dataDisks = {
        disk1 = "/mnt/disks/disk1";
        disk2 = "/mnt/disks/disk2";
        disk3 = "/mnt/disks/disk3";
        disk4 = "/mnt/disks/disk4";
      };
      contentFiles = [
        "/var/lib/snapraid.content"
        "/mnt/disks/disk1/.snapraid.1.content"
        "/mnt/disks/disk2/.snapraid.2.content"
        "/mnt/disks/disk3/.snapraid.3.content"
        "/mnt/disks/disk4/.snapraid.4.content"
      ];
    };

    syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;
      settings = {
        devices =
          let
            devices = config.homelab.syncthing.devices;
          in
          {
            pixel6.id = devices.pixel6;
            laptop.id = devices.laptop;
          };
        folders = {
          logseq = {
            path = "/mnt/user/documents/logseq";
            devices = [
              "pixel6"
              "laptop"
            ];
            versioning.type = "simple";
          };
          camera = {
            path = "/mnt/user/images/photos/pixel6";
            devices = [ "pixel6" ];
            versioning.type = "simple";
            ignoreDelete = true;
          };
          whatsapp = {
            path = "/mnt/user/backups/whatsapp-media";
            devices = [ "pixel6" ];
            ignoreDelete = true;
          };
          phoneBackups = {
            path = "/mnt/user/backups/pixel6";
            devices = [ "pixel6" ];
            versioning.type = "simple";
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ smartmontools ];

  systemd.services.hd-idle = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart = [ "${pkgs.hd-idle}/bin/hd-idle -i 300" ];
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
