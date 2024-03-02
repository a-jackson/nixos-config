{ config, pkgs, ... }:
let 
user = config.services.audiobookshelf.user;
group = config.homelab.multimedia.group;
in
{
  systemd.tmpfiles.rules = [ 
    "d /data/audio/books 0770 ${user} ${group} - -"
    "d /data/audio/aax 0700 ${user} ${group} - -"
  ];

  services = {
    audiobook-extractor = {
      enable = true;
      user = user;
      group = group;
      profiles.andrew = {
        destinationDir = "/data/audio/books";
        completeDir = "/data/audio/aax";
        tempDir = "/tmp/abe-andrew";
        startAt = "Mon *-*-* 06:00:00";
      };
      profiles.gemma = {
        destinationDir = "/data/audio/books";
        completeDir = "/data/audio/aax";
        tempDir = "/tmp/abe-gemma";
        startAt = "Tue *-*-* 06:00:00";
      };
    };
    audiobookshelf = {
      enable = true;
      port = 13378;
      inherit group;
    };
  };
}
