{ pkgs, ... }:
{
  imports = [ ./shell.nix ];

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
      extraConfig = {
        credential.helper = "store";
        pull.rebase = true;
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        rebase = {
          autoStash = true;
          autoSquash = true;
          updateRefs = true;
        };
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "-version:refname";
        init.defaultBranch = "main";
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
      };
      difftastic.enable = true;
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
        };
      };
    };
    gh-dash.enable = true;

    ssh.enable = true;
    gpg = {
      enable = true;
      settings = {
        pinentry-mode = "loopback";
      };
    };
    fzf.enable = true;
    fd.enable = true;
    lazygit.enable = true;
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-tty;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };

    ssh-agent.enable = true;
  };

  home.packages =
    with pkgs;
    let
      get_password = writeShellScript "get-password" ''${bitwarden-cli}/bin/bw get password "$(cat /etc/hostname) SSHKey Passphrase"'';
    in
    [
      (writeShellScriptBin "init-ssh" ''SSH_ASKPASS_REQUIRE="force" SSH_ASKPASS="${get_password}" ssh-add'')
      bitwarden-cli
      sops
      jq
      gcc
      nodejs_22
      tea
      fd
    ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];
}
