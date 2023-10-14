{ pkgs, ... }:
{
  programs = {
    gnupg.agent = {
      enable = true;
    };
  };

  users.users.andrew = {
    packages = with pkgs; [
      sops
      nixpkgs-fmt
    ];
  };

  home-manager.users.andrew = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      keybindings = [{
        key = "ctrl+shift+s";
        command = "workbench.action.files.saveFiles";
      }];
    };
  };
}
