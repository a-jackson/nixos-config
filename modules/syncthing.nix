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
      nas = "EMICLV6-2YVPH5S-Y4ILGMP-SSKTA5J-XWN3JR7-RGSJBDR-QJ5ABRO-6IKCIQU";
    };
  };
}
