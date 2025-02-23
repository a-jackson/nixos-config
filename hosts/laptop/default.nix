{
  username,
  pkgs,
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
    nvim.csharp = true;
    nvim.rust = true;
  };

  environment.systemPackages = with pkgs; [
    darktable
    dotnetCorePackages.dotnet_8.sdk
    kdePackages.kdenlive
    nfs-utils
    bottles
    jetbrains.rider
    siril
    gimp
    rustc
    cargo
    rustfmt
  ];

  environment.variables = {
    DOTNET_ROOT = pkgs.dotnetCorePackages.dotnet_8.sdk;
  };

  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  systemd.mounts =
    let
      nasMount = folder: {
        type = "nfs";
        mountConfig = {
          Options = "noatime,nfsvers=4.2";
        };
        what = "192.168.1.75:/mnt/user/${folder}";
        where = "/mnt/user/${folder}";
      };
    in
    [
      (nasMount "video")
      (nasMount "images")
      (nasMount "audio")
    ];
  systemd.automounts =
    let
      nasMount = folder: {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/mnt/user/${folder}";
      };
    in
    [
      (nasMount "video")
      (nasMount "images")
      (nasMount "audio")
    ];

}
