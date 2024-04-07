{
  username,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      21027
      22000
    ];
  };

  homelab = {
    root = {
      diskLabel = "kerberos";
      ephemeralBtrfs.enable = true;
    };
    impermanence.enable = true;
    restic = {
      daily = {
        paths = [
          "/persist"
          "/home"
        ];
        exclude = [
          "/home/andrew/.cache"
          "/home/andrew/.nuget"
          "/home/andrew/.npm"
          "**/node_modules/"
        ];
      };
    };
    homeType = "gnome";
    nvim.csharp = true;
  };

  environment.systemPackages = with pkgs; [ (with dotnetCorePackages; combinePackages [ sdk_8_0 ]) ];

  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    dataDir = "/home/${username}";
    openDefaultPorts = true;
    settings.devices =
      let
        devices = config.homelab.syncthing.devices;
      in
      {
        pixel6.id = devices.pixel6;
        nas.id = devices.nas;
      };
    settings.folders = {
      logseq = {
        path = "/home/andrew/documents/Logseq";
        devices = [
          "pixel6"
          "nas"
        ];
      };
    };
  };
}
