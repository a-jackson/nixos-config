{ pkgs, ... }:
{
  imports = [ ./zellij.nix ];

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

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set __fish_git_prompt_show_informative_status 1
        set __fish_git_prompt_showupstream 1
        fzf_configure_bindings --git_log=\e\cg
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
                rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
                sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
              }
              + /palettes/${flavour}.toml
            )
          );
      };

    ssh = {
      enable = true;
    };

    gpg = {
      enable = true;
      settings = {
        pinentry-mode = "loopback";
      };
    };

    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      historyLimit = 100000;
      prefix = "C-s";
      keyMode = "vi";
      sensibleOnTop = false;
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      plugins = with pkgs.tmuxPlugins; [
        better-mouse-mode
        vim-tmux-navigator
        {
          plugin = (
            catppuccin.overrideAttrs (o: {
              src = pkgs.fetchFromGitHub {
                owner = "catppuccin";
                repo = "tmux";
                rev = "843946e1761c48b408aea6aec48633dcc4b70988";
                hash = "sha256-EtNKbpTsNvhLAmAbP79G2jcPO9yvya4d41xY6IZOc3o=";
              };
            })
          );
          extraConfig = ''
            set -g @catppuccin_window_left_separator "█"
            set -g @catppuccin_window_right_separator "█ "
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_middle_separator "  █"

            set -g @catppuccin_window_default_fill "number"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#{pane_current_path}"

            set -g @catppuccin_status_modules_right "application date_time"
            set -g @catppuccin_status_left_separator  ""
            set -g @catppuccin_status_right_separator " "
            set -g @catppuccin_status_right_separator_inverse "yes"
            set -g @catppuccin_status_fill "all"
            set -g @catppuccin_status_connect_separator "no"
          '';
        }
      ];
      extraConfig = ''
        bind u split-window -h -c "#{pane_current_path}"
        bind y split-window -v -c "#{pane_current_path}"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        set -g status-position top
        set -g focus-events on
        set-option -sa terminal-features ',xterm-256color:RGB'
        set-option -sg escape-time 10
      '';
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    fzf.enable = true;
    htop.enable = true;
    btop.enable = true;
    direnv.enable = true;
    ripgrep.enable = true;
    bat.enable = true;
    fd.enable = true;
    lazygit.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  services.ssh-agent.enable = true;

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
