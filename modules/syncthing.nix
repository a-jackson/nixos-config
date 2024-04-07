{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.homelab.syncthing = {
    devices = mkOption { type = types.attrsOf types.str; };
  };

  config = {
    homelab.syncthing.devices = {
      pixel6 = "EEXQYJ6-CAAT3CE-LEC572W-4FXNLVB-JPYKAG2-O34CYXN-VRQBNDL-ABOGFAL";
      laptop = "JAZS5Z5-OZZ6RWN-4IKXMQA-ZA2PQCU-HIAKM2L-5WGWKI2-VNLOCJF-NE4GWAH";
      nas = "";
    };
  };
}
