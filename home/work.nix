{ pkgs, lib, ... }:
{
  imports = [
    ./common/shell.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    awscli2
    terraform
  ];

  programs = {
    git = {
      userEmail = lib.mkForce "andrew.jackson@dataflexnet.com";
      signing = {
        key = "6A85604C5E59DEFB";
        signByDefault = true;
      };
      aliases = {
        changelog = "!git log --format='* %s' --reverse --no-decorate --no-merges \${1-planned-release-dev}..HEAD";
        start = "!DEFAULT=$(git default) && git localtrim && git switch --no-track -c $1 origin/\${2-$DEFAULT} #";
        default = "!(git show-ref --verify --quiet refs/heads/planned-release-dev && echo planned-release-dev) || (git show-ref --verify --quiet refs/heads/master && echo master)";
        rd = "!DEFAULT=$(git default) && git checkout -B $DEFAULT origin/$DEFAULT";
      };
      includes = [{
        condition = "gitdir/i:~/repos/personal/";
        contents = {
          user.Email = "andrew@a-jackson.co.uk";
          commit.gpgsign = false;
        };
      }];
    };

    gh = {
      settings = {
        aliases = {
          pr-devops = "!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed \"s/-/ /2g\"`;gh pr create --title \"$title\" --body \"$changelog\" --reviewer adamwillden --reviewer markdfn --reviewer bryanpep --reviewer AltheusII";
          pr-dps = "!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed \"s/-/ /2g\"`;gh pr create --title \"$title\" --body \"$changelog\" --reviewer martynguest --reviewer chrisjward67";
          pr-edit = "!default_branch=`git default`;changelog=`git changelog origin/$default_branch`;title=`git head | sed \"s/-/ /2g\"`;gh pr edit -b \"$changelog\" -t \"$title\"";
        };
      };
    };
  };
}
