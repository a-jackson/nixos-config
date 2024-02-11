{ config, lib, ... }: with lib;
let
  cfg = config.homelab.monitoring;
in
{
  options.homelab.monitoring = {
    enable = mkEnableOption "Enable monitoring";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters = {
      smartctl.enable = true;
      smartctl.openFirewall = true;
      node.enable = true;
      node.openFirewall = true;
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
    '';
  };
}
