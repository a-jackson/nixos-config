{ ... }:
{
  services.mako = {
    enable = true;
    anchor = "top-right";
    borderRadius = 2;
    borderSize = 2;
    icons = true;
    actions = true;
    layer = "top";
    markup = true;
    height = 100;
    width = 300;
    defaultTimeout = 15000;
    sort = "+time";
    extraConfig = ''
      on-button-left=dismiss
      on-button-right=dismiss-all
      padding=15
      max-icon-size=128
      icon-location=left
      history=1
      text-alignment=left
    '';
  };
}
