{ pkgs, ... }:
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

  home.persistence."/persist/home/andrew" = {
    allowOther = true;
    directories = [
      ".config/VSCodium"
    ];
  };
}
