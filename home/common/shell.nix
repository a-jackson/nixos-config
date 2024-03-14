{ pkgs, ... }: {
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
        fixup =
          "!sh -c '(git diff-files --quiet || (echo Unstaged changes, please commit or stash with --keep-index; exit 1)) && COMMIT=$(git rev-parse $1) && git commit --fixup=$COMMIT && git -c sequence.editor=: rebase -i --autosquash $COMMIT~1' -";
        pu =
          "!f() { BRANCH=$(git head) && git push --set-upstream origin $BRANCH; }; f";
        head = "rev-parse --abbrev-ref HEAD";
        localtrim =
          "!f() { git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done; }; f";
        pf = "push --force-with-lease";
      };
      extraConfig = { credential.helper = "store"; };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = { co = "pr checkout"; };
      };
    };

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

    ssh = { enable = true; };

    gpg = { enable = true; };

    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      historyLimit = 100000;
      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.sensible
      ];
      extraConfig = "";
    };

    zellij.enable = true;
    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    fzf.enable = true;
    htop.enable = true;
    direnv.enable = true;
    ripgrep.enable = true;
  };

  services.gpg-agent.enable = true;
  # services.gpg-agent.pinentryFlavor = "curses";

  home.packages = with pkgs; [
    home-manager
    sops
    nixpkgs-fmt
    jq
    gcc
    nodejs_20
    tea
    # (python312.withPackages (ps: with ps; []))
  ];
}
