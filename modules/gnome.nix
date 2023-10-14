{ ... }:
{
  services = {
    xserver = {
      enable = true;
      layout = "gb";
      libinput.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.dconf.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  home-manager.users.andrew = {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "codium.desktop"
          "org.gnome.Console.desktop"
        ];
        welcome-dialog-last-shown-version = "44.3";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-applications = [ ];
        switch-applications-backward = [ ];
        switch-windows = [ "<Alt>Tab" ];
        switch-windows-backward = [ "<Shift><Alt>Tab" ];
      };
    };
  };
}
