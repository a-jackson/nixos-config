{ pkgs, config, ... }:
{

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

  home.packages = with pkgs; [
    sops
    nixpkgs-fmt
  ];

  home.persistence."/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/VSCodium"
    ];
  };
}
