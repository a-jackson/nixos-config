{ ... }: {
  imports = [
    ./comment.nix
    ./gitsigns.nix
    ./lsp.nix
    ./navigation.nix
    ./options.nix
    ./telescope.nix
    ./terminal.nix
    ./treesitter.nix
    ./ui.nix
  ];
  config = {
    plugins.yanky.enable = true;
    plugins.yanky.highlight.timer = 100;
    plugins.auto-save.enable = true;
    plugins.auto-session.enable = true;
    plugins.auto-session.bypassSessionSaveFileTypes = [ "neo-tree" ];
    extraConfigVim = ''
      let g:auto_session_pre_save_cmds = ["Neotree close"]
    '';
  };

}