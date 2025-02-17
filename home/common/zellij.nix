{ lib, pkgs, ... }:
let
  inherit (lib) mkOrder getExe;
  zellijCmd = getExe pkgs.zellij;
in
{
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
  };

  home.file.zellij = {
    target = ".config/zellij/config.kdl";
    source = ./zellij-config.kdl;
  };

  programs.fish.interactiveShellInit = (
    mkOrder 200 ''
      if not set -q ZELLIJ
          ${zellijCmd} attach -c main || zellij

          kill $fish_pid
      end
    ''
  );
}
