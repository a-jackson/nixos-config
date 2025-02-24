{ pkgs, lib, ... }:
{
  imports = [
    ./common/shell.nix
    ../modules/nixvim
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    awscli2
    home-manager
    terraform
    terraform-ls
    omnisharp-roslyn
    tflint
    packer
    (
      with dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_9_0
      ]
    )
    (python312.withPackages (
      ps: with ps; [
        boto3
        boto3-stubs
        mypy-boto3-s3
        mypy-boto3-dynamodb
        mypy-boto3-ssm
      ]
    ))
    openssl
    slides
    graph-easy
  ];

  homelab.nvim = {
    enable = true;
    terraform = true;
    csharp = true;
  };

  programs = {
    nixvim.plugins.copilot-cmp.enable = true;
    nixvim.plugins.cmp.settings.sources = [ { name = "copilot"; } ];

    git = {
      userEmail = lib.mkForce "andrew.jackson@dataflexnet.com";
      signing = {
        key = "6A85604C5E59DEFB";
        signByDefault = true;
      };
      aliases = {
        changelog = "!git log --format='* %s' --reverse --no-decorate --no-merges \${1-planned-release-dev}..\${2-HEAD}";
        start = "!DEFAULT=$(git default) && git localtrim && git switch --no-track -c $1 origin/\${2-$DEFAULT} #";
        default = "!(git show-ref --verify --quiet refs/heads/planned-release-dev && echo planned-release-dev) || (git show-ref --verify --quiet refs/heads/master && echo master)";
        rd = "!DEFAULT=$(git default) && git checkout -B $DEFAULT origin/$DEFAULT";
      };
      includes = [
        {
          condition = "gitdir/i:~/repos/personal/";
          contents = {
            user.Email = "andrew@a-jackson.co.uk";
            commit.gpgsign = false;
          };
        }
      ];
    };

    gh = {
      settings = {
        aliases = {
          pr-devops = ''!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed "s/-/ /2g"`;gh pr create --title "$title" --body "$changelog" --reviewer adamwillden --reviewer markdfn --reviewer bryanpep --reviewer AltheusII'';
          pr-dps = ''!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed "s/-/ /2g"`;gh pr create --title "$title" --body "$changelog" --reviewer martynguest --reviewer chrisjward67'';
          pr-edit = ''!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed "s/-/ /2g"`;gh pr edit -b "$changelog" -t "$title"'';
          deploy-changes = ''!env=$1;shift;sha=$(gh api "repos/$(gh repo view --json nameWithOwner -q ".nameWithOwner")/deployments?environment=$env" -q ".[0].sha");git changelog $sha $(git default) "$@"'';
        };
      };
    };

    fish.interactiveShellInit = lib.mkOrder 200 ''
      function __fish_complete_aws
        env COMP_LINE=(commandline -cp) ${pkgs.awscli2}/bin/aws_completer | tr -d ' '
      end
      complete -c aws -f -a "(__fish_complete_aws)"
    '';
  };
}
