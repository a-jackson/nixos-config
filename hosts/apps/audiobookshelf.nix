{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "ghcr.io/advplyr/audiobookshelf";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/advplyr/audiobookshelf";
      imageDigest = "sha256:34bc1414a7a65f3f1e12f3e03195561732cc740792d1dea1858d483006ceba1e";
      sha256 = "sha256-LtYw4ND8WS97p9qJLm03G6P4nQ/dACwoERrcsfNQvj0=";
    };
    ports = [
      "13378:80"
    ];
    volumes = [
      "/mnt/user/audio/books/Audiobook:/audiobooks"
      "/mnt/user/audio/podcasts:/podcasts"
      "audiobookshelf_config:/config"
      "audiobookshelf_metadata:/metadata"
    ];
  };
}
