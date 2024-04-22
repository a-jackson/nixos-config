{ pkgs, ... }:
{

  # tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Brightness and volume control
  # https://haikarainen.github.io/light/
  programs.light.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/143365
  security.pam.services.swaylock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.gnome.gnome-keyring.enable = true;

  # Enabling hyprlnd on NixOS
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible, set this to 1
    WLR_NO_HARDWARE_CURSORS = "0";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  # https://www.freedesktop.org/software/systemd/man/logind.conf.html
  services.logind.extraConfig = ''
    IdleActionSec=900
    IdleAction=suspend-then-hibernate
    HandleLidSwitch=suspend-then-hibernate
    HandleLidSwitchDocked=ignore
    HandleLidSwitchExternalPower=suspend
  '';

  # https://www.systutorials.com/docs/linux/man/5-systemd-sleep.conf/
  # HibernateDelaySec is the amount of time the
  # system sleeps before entering hibernate when
  # using suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=600
  '';

  # XDG portal
  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # system packages
  environment.systemPackages = with pkgs; [
    waybar # taskbar
    libnotify # Notification libraries
    mako # Notification daemon
    kitty # Terminal emulator
    grim # Screenshots
    slurp # Screenshots
    wl-clipboard # Clipboard
    font-awesome # Fonts
    libinput-gestures # Gesture Control
    playerctl # Control sublime-music from waybar?
    pavucontrol # Pulse Audio Volume CONTROL glib # Set GTK theme settings
    greetd.tuigreet # Greeter
    swayidle # Idle management daemon - Automatic lock screen
    swayosd # used for on-screen notifications for things like adjusting backlight, volume, etc
    wlogout # Logout/shutdown/hibernate/lock screen modal UI
    ranger # TUI file manager
    xdg-utils # Utilities for better X/Wayland integration
    pulsemixer # TUI Pipewire  / volume management
    udiskie # Automatic device mounting

    # Themes
    gruvbox-gtk-theme # Gruvbox Theme
    papirus-icon-theme # Papirus Icons

    rofi-wayland # App Launcher

    # wayland-packages
    # inputs.nixpkgs-wayland.packages.${system}.wayprompt # from nixpkgs-wayland exclusively - pinentry UI
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
