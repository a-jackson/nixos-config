{ lib, pkgs, ... }:
{
  imports = [ ./zellij.nix ];

  programs = {

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set __fish_git_prompt_show_informative_status 1
        set __fish_git_prompt_showupstream 1
        fzf_configure_bindings --git_log=\e\cg
        yes | fish_config theme save "Catppuccin Mocha"
      '';
      plugins = [
        {
          name = "fzf.fish";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "v10.3";
            sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
          };
        }
      ];
    };

    bash.enable = true;

    starship =
      let
        flavour = "mocha";
      in
      {
        enable = true;
        settings =
          {
            # Other config here
            format = "$all"; # Remove this line to disable the default prompt format
            palette = "catppuccin_${flavour}";
          }
          // builtins.fromTOML (
            builtins.readFile (
              pkgs.fetchFromGitHub {
                owner = "catppuccin";
                repo = "starship";
                rev = "e99ba6b210c0739af2a18094024ca0bdf4bb3225";
                sha256 = "sha256-1w0TJdQP5lb9jCrCmhPlSexf0PkAlcz8GBDEsRjPRns=";
              }
              + /themes/${flavour}.toml
            )
          );
      };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    htop.enable = true;
    btop.enable = true;
    ripgrep.enable = true;
    bat.enable = true;

  };

  nix.gc.automatic = true;

  xdg.configFile =
    let
      catppuccin-fish = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "fish";
        rev = "cc8e4d8fffbdaab07b3979131030b234596f18da";
        sha256 = "sha256-udiU2TOh0lYL7K7ylbt+BGlSDgCjMpy75vQ98C1kFcc=";
      };
    in
    {
      "fish/themes/Catppuccin Mocha.theme".source = "${catppuccin-fish}/themes/Catppuccin Mocha.theme";
    };

  home.packages = [ pkgs.home-manager ];

  systemd.user.services."home-manager-gc" = {
    Unit = {
      Description = "Home Manager Garbage Collection";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.home-manager} expire-generations -7days";
    };
    Install.WantedBy = [ "default.target" ];

  };

  systemd.user.timers."home-manager-gc" = {
    Unit.Description = "Run Home Manager Garbage Collection Daily";

    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
