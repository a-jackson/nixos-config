{ ... }:
{
  options.homelab.nfs = { };

  config = {
    services.nfs.server = {
      enable = true;
      exports = ''
        "/mnt/user/audio" -fsid=108,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
        "/mnt/user/images" -fsid=107,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
        "/mnt/user/video" -fsid=105,async,no_subtree_check *(rw,sec=sys,insecure,anongid=100,anonuid=99,all_squash)
      '';
    };

    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
