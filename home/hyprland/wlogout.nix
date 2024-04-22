{ config, ... }:
{

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "swaylock";
        text = "Lock";
        circular = true;
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        circular = true;
        keybind = "h";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        circular = true;
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        circular = true;
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        circular = true;
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        circular = true;
        keybind = "r";
      }
    ];
  };
  #     xdg.configFile."wlogout/style.css" = {
  #         enable = true;
  #         target = "./wlogout/style.css";
  #         text = ''
  #             * {
  #                 background-image: none;
  #             }
  #             window {
  #                 background-color: #${config.lib.stylix.colors.base00};
  #             }
  #             button {
  #                 color: #${config.lib.stylix.colors.base04};
  #                 font-size: 24px;
  #                 border-radius: 5000px;
  #                 margin: 25px;
  #                 background-color: #${config.lib.stylix.colors.base02};
  #                 border-style: solid;
  #                 border-width: 3px;
  #                 background-repeat: no-repeat;
  #                 background-position: center;
  #                 background-size: 25%;
  #             }
  #             button:active, button:hover {
  #                 background-color: #${config.lib.stylix.colors.base08};
  #                 color: #${config.lib.stylix.colors.base00};
  #                 outline-style: none;
  #             }
  #
  #             #lock { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/lock.png"); }
  #             #logout { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/logout.png"); }
  #             #suspend { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/suspend.png"); }
  #             #hibernate { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/hibernate.png"); }
  #             #shutdown { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/shutdown.png"); }
  #             #reboot { background-image: url("/etc/nixos/git/home-manager/common/desktops/hyprland/assets/wlogout/reboot.png"); }
  #         '';
  #     };
}
