{ pkgs, lib, config, ... }:
{

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    steam
    protontricks
  ];

  home.persistence."/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".factorio"
      {
        # A couple of games don't play well with bindfs
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
  };
}
