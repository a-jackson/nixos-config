{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        jnoortheen.nix-ide
      ];
    })
  ];

  programs = {
    gnupg.agent = {
      enable = true;
    };
  };

  users.users.andrew = {
    packages = with pkgs; [
      sops
      gh
      nixpkgs-fmt
    ];
  };
}
