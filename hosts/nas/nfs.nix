{ ... }: {
  options.homelab.nfs = { };

  config = {
    services.nfs = {
      enable = true;
      exports = ''
        "/mnt/user/appdata" -fsid=106,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
        "/mnt/user/audio" -fsid=108,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
        "/mnt/user/images" -fsid=107,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
        "/mnt/user/video" -fsid=105,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
      '';
    };
  };
}
