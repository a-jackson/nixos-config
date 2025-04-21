{
  config,
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
      diskLabel = "desktop";
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
          "/home/andrew/Pictures/**/process/"
        ];
      };
    };
    nvim.csharp = true;
    nvim.rust = true;
    nvim.terraform = true;
  };

  hardware.graphics = {
    enable = true;
  };

  environment =
    with pkgs;
    let
      dotnet = (
        with dotnetCorePackages;
        combinePackages [
          dotnet_8.sdk
          dotnet_9.sdk
        ]
      );
    in
    {
      systemPackages = with pkgs; [
        darktable
        dotnet
        nfs-utils
        bottles
        jetbrains.rider
        siril
        gimp
        rustc
        cargo
        rustfmt
        kdePackages.kdenlive
        opentofu
        terraform-ls
        awscli2
      ];

      variables = {
        DOTNET_ROOT = "${dotnet}/share/dotnet";
      };
    };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
