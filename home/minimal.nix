{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [ ./common ];

  programs = {
    git.enable = mkForce false;
    gh.enable = mkForce false;
    gh-dash.enable = mkForce false;
    ssh.enable = mkForce false;
    gpg.enable = mkForce false;
    tmux.enable = mkForce false;
    zoxide.enable = mkForce false;
    fzf.enable = mkForce false;
    htop.enable = mkForce false;
    direnv.enable = mkForce false;
    ripgrep.enable = mkForce false;
    bat.enable = mkForce false;
    fd.enable = mkForce false;
  };
  services = {
    gpg-agent.enable = mkForce false;
    ssh-agent.enable = mkForce false;
  };
}
