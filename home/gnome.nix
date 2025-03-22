{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./common
    ./common/desktop.nix
    ./common/firefox.nix
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "kitty.desktop"
      ];
      welcome-dialog-last-shown-version = "44.3";
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        status-icons.extensionUuid
        space-bar.extensionUuid
        switcher.extensionUuid
        tactile.extensionUuid
        just-perfection.extensionUuid
      ];
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
    };
    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-activate-workspace-shortcuts = false;
    };
    "org/gnome/shell/extensions/space-bar/behavior" = {
      smart-workspace-names = false;
      always-show-numbers = true;
      indicator-style = "workspaces-bar";
    };
    "org/gnome/shell/extensions/switcher" = {
      show-switcher = [ "<Super>space" ];
      font-size = lib.hm.gvariant.mkUint32 18;
      icon-size = lib.hm.gvariant.mkUint32 24;
      fade-enable = true;
    };
    "org/gnome/shell/extensions/tactile" = {
      col-0 = 2;
      col-1 = 1;
      col-2 = 1;
      col-3 = 2;
      show-tiles = "<Super>+t";
    };
    "org/gnome/shell/extensions/just-perfection" = {
      accent-color-icon = true;
      accessibility-menu = false;
      activities-button = true;
      animation = 2;
      calendar = true;
      clock-menu = true;
      clock-menu-position-offset = 0;
      dash = true;
      dash-app-running = true;
      dash-icon-size = 0;
      dash-separator = true;
      events-button = true;
      invert-calendar-column-items = false;
      max-displayed-search-results = 0;
      osd = true;
      panel = true;
      panel-in-overview = true;
      quick-settings = true;
      quick-settings-airplane-mode = true;
      quick-settings-dark-mode = false;
      ripple-box = true;
      screen-sharing-indicator = false;
      search = false;
      show-apps-button = true;
      startup-status = 1;
      support-notifier-showed-version = 34;
      support-notifier-type = 0;
      theme = true;
      top-panel-position = 0;
      weather = false;
      window-demands-attention-focus = false;
      window-picker-icon = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-peek = true;
      workspace-popup = true;
      workspaces-in-app-grid = true;
      world-clock = false;
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "compact";
        tweaks = [ "black" ];
        variant = "mocha";
      };
    };
  };

  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.dotnet/tools/" ];

  home.packages = with pkgs.gnomeExtensions; [
    status-icons
    space-bar
    switcher
    tactile
    just-perfection
  ];
}
