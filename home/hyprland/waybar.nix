{ config, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [
          "custom/wlogout"
          "idle_inhibitor"
          "clock"
          "mpris"
        ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [
          "privacy"
          "hyprland/submap"
          "pulseaudio"
          "custom/tailscale"
          "network"
          "battery"
        ];

        # Modules
        gamemode = {
          "format" = "{glyph}";
          "format-alt" = "{glyph} {count}";
          "glyph" = "";
          "hide-not-running" = true;
          "use-icon" = true;
          "icon-name" = "input-gaming-symbolic";
          "icon-spacing" = 4;
          "icon-size" = 20;
          "tooltip" = true;
          "tooltip-format" = "Games running: {count}";
        };
        "custom/wlogout" = {
          format = "";
          on-click = "wlogout";
        };
        "custom/tailscale" = {
          format = "{icon}";
          exec = "$HOME/.config/waybar/scripts/tailscale.sh";
          exec-if = "pgrep tailscaled";
          return-type = "json";
          interval = 5;
          format-icons = {
            Running = "󰌆";
            Stopped = "󰌊 ";
          };
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = ''{status_icon} <i>{dynamic}</i>'';
          player-icons = {
            default = "▶ ";
          };
          status-icons = {
            paused = "⏸";
          };
          max-length = 30;
        };
        "hyprland/workspaces" = {
          on-click = "activate";
        };
        clock = {
          format = "󰥔  {:%H:%M}";
          format-alt = "󰃭  {:%A, %d %b, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "left";
            on-scroll = 1;
            format = {
              months = "<b>{}</b>";
              days = "<b>{}</b>";
              weeks = "<b>W{}</b>";
              weekdays = "<b>{}</b>";
              today = "<b><u>{}</u></b>";
            };
          };
          actions = {
            on-click-right = "kitty -e calcurse";
            on-click-middle = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        pulseaudio = {
          scroll-step = 1;
          format = "{icon}{format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " ";
          format-muted = "󰝟 {format_source}";
          format-source = " ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            headset = " ";
            default = [
              "󰕿 "
              "󰖀 "
              "󰕾 "
            ];
          };
          tooltip = false;
          on-click = "kitty -e pulsemixer";
        };
        network = {
          format = "{ifname}";
          format-wifi = "";
          format-ethernet = " ";
          format-disconnected = ""; # Hides the module
          tooltip-format = "{ifname} via {gwaddr} ";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} \n{ipaddr}";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
          on-click = "kitty --class=nmtui -e nmtui";
        };
        battery = {
          tooltip = true;
          tooltip-format = "{time}";
          states = {
            warning = 35;
            critical = 20;
          };
          format = "{icon}   {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-plugged = "   {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
      };
    };
    style = ''
      * {
          border: none;
          border-radius: 0;

      }

      #waybar {
          padding: 15px;
      }

      #workspaces button.visible,
      #workspaces button {
          font-size: 15px;
          border-radius: 50px;
          padding: 0px 5px;
          margin: 5px;
      }

      #workspaces button.active {
          background-color: #${config.lib.stylix.colors.base04};
          color: #${config.lib.stylix.colors.base00};
          padding: 0px 15px;
      }

      #workspaces button:hover,
      #workspaces button.focused:hover,
      #workspaces button.visible:hover  {
          background-color: #${config.lib.stylix.colors.base07};
          color: #${config.lib.stylix.colors.base00};
      }

      #workspaces button.urgent {
          background-color: #${config.lib.stylix.colors.base09};
          color: #${config.lib.stylix.colors.base00};
      }

      /*
      * General background
      */
      #gamemode,
      #privacy,
      #network,
      #mpris,
      #memory,
      #backlight,
      #cpu,
      #pulseaudio,
      #temperature,
      #battery,
      #tray,
      #submap,
      #clock,
      #idle_inhibitor,
      #custom-tailscale,
      #custom-wlogout,
      #window {
          font-size: 16px;
          /*padding: 0px 10px;*/
          margin: 5px;
          border-radius: 3px;
          font-weight: normal;
      }

      /*
      * General background
      */
      #privacy #button:hover,
      #network button:hover,
      #mpris button:hover,
      #memory button:hover,
      #backlight button:hover,
      #cpu button:hover,
      #pulseaudio button:hover,
      #temperature button:hover,
      #battery button:hover,
      #tray button:hover,
      #submap button:hover,
      #clock button:hover,
      #idle_inhibitor button:hover,
      #custom-tailscale button:hover,
      #custom-wlogout button:hover,
      #window button:hover{
          background-color: #${config.lib.stylix.colors.base00};
      }

      /*
      * Warning plugins state
      */
      #battery.warning {
          background-color: #${config.lib.stylix.colors.base0A};
          color: #${config.lib.stylix.colors.base00};
      }

      /*
      * Critical plugins state
      */
      #idle_inhibitor.activated,
      #battery.critical,
      #custom-tailscale.Stopped,
      #network.disconnected {
          background-color: #${config.lib.stylix.colors.base08};
          color: #${config.lib.stylix.colors.base00};
      }
      #battery.charging {
          background-color: #${config.lib.stylix.colors.base0C};
          color: #${config.lib.stylix.colors.base00};
      }
      #battery.plugged {}
      #pulseaudio.bluetooth {}
      tooltip {
          font-size: 14px;
      }
    '';
  };
}
