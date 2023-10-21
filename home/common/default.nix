{ pkgs, lib, config, ... }:
{
  programs = {
    git = {
      enable = true;
      userEmail = "andrew@a-jackson.co.uk";
      userName = "Andrew Jackson";
      aliases = {
        co = "checkout";
        ci = "commit";
        br = "branch";
        st = "status";
        sw = "switch";
        amend = "commit --amend --no-edit";
        branches = "branch --all";
        hist = "log --decorate --oneline --graph";
        nuke = "clean -dfx";
        fixup = "!sh -c '(git diff-files --quiet || (echo Unstaged changes, please commit or stash with --keep-index; exit 1)) && COMMIT=$(git rev-parse $1) && git commit --fixup=$COMMIT && git -c sequence.editor=: rebase -i --autosquash $COMMIT~1' -";
        pu = "!f() { BRANCH=$(git head) && git push --set-upstream origin $BRANCH; }; f";
        head = "rev-parse --abbrev-ref HEAD";
        localtrim = "!f() { git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done; }; f";
        pf = "push --force-with-lease";
      };
    };

    gh.enable = true;
    gh-dash.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set __fish_git_prompt_show_informative_status 1
        set __fish_git_prompt_showupstream 1
      '';
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    ssh = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    home-manager
  ];

  home.persistence."/persist/home/andrew" = {
    allowOther = true;
    directories = [
      "repos"
      ".local/share/keyrings"
      ".gnupg"
      ".ssh"
      ".mozilla"
    ];
    files = [
      ".config/monitors.xml"
    ];
  };

  home = {
    username = lib.mkDefault "andrew";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = "23.05";
  };
}
