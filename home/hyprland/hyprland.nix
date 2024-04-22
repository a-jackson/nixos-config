{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [ ];
    extraConfig = ''
      # Resize
      bind = SUPER, R, exec, notify-send 'Entered resize mode.  Press ESC to quit.'
      bind = SUPER, R, submap, resize
      submap = resize
      binde = , H, resizeactive,-50 0
      binde = , L, resizeactive,50 0
      binde = , K, resizeactive,0 -50
      binde = , J, resizeactive,0 50
      binde = , left, resizeactive,-50 0
      binde = , right, resizeactive,50 0
      binde = , up, resizeactive,0 -50
      binde = , down, resizeactive,0 50
      bind  = , escape, submap, reset
      submap = reset
    '';
    settings = {
      layerrule = [
        "blur, waybar"
        "blur, rofi"
        "blur, notifications"
        "ignorezero, notifications"
      ];
      xwayland.force_zero_scaling = false;
      general = {
        gaps_in = "5";
        gaps_out = "10";
        border_size = "1";
        resize_on_border = "true";
        extend_border_grab_area = "15";
        layout = "dwindle";
      };
      input = {
        kb_layout = "us";
        follow_mouse = "1";
        mouse_refocus = false;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          clickfinger_behavior = true;
          drag_lock = true;
        };
        sensitivity = 0;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_numbered = false;
      };
      misc = {
        disable_hyprland_logo = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };
      decoration = {
        rounding = 3;
        active_opacity = 0.75;
        inactive_opacity = 0.6;
        fullscreen_opacity = 1.0;
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        blur = {
          size = 6;
          passes = 3;
          ignore_opacity = true;
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows,1,7,myBezier"
          "windowsOut,1,7,default,popin 80%"
          "border,1,10,default"
          "borderangle,1,8,default"
          "fade,1,7,default"
          "workspaces,1,6,default"
        ];
      };
      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
        no_gaps_when_only = 1; # If it's the only window int he layout, 1=don't show gaps
      };
      master.new_is_master = true;
      windowrule = [
        "noblur,^(firefox)$" # disables blur for firefox
        "opacity 1.0 override,^(firefox)$" # Sets opacity to 1
        "noblur,^(steam)$" # disables blur for steam
        "opacity 1.0 override,^(steam)$" # Sets opacity to 1
        "noblur,^(codium)$" # disables blur for codium
        "opacity 0.9 override,^(codium)$" # Sets opacity to 1
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
      ];
      bind = [
        ''SUPER, Q, exec, kitty''
        ''SUPER, C, killactive,''
        ''SUPER, M, exit,''
        ''SUPER, V, togglefloating,''
        ''SUPER, P, pseudo, # dwindle''
        ''SUPER, J, togglesplit, # dwindle''
        ''SUPER, F, exec, firefox''
        ''SUPER, S, exec, steam -vgui''
        ''SUPER, B, exec, rofi-rbw --action copy --no-folder''

        # Move focus with mainMod + arrow keys
        ''SUPER_ALT, left, movefocus, l''
        ''SUPER_ALT, right, movefocus, r''
        ''SUPER_ALT, up, movefocus, u''
        ''SUPER_ALT, down, movefocus, d''

        ''SUPER_ALT, H, movefocus, l''
        ''SUPER_ALT, L, movefocus, r''
        ''SUPER_ALT, K, movefocus, u''
        ''SUPER_ALT, J, movefocus, d''

        # Switch workspaces with mainMod + [0-9]
        ''SUPER, 1, workspace, 1''
        ''SUPER, 2, workspace, 2''
        ''SUPER, 3, workspace, 3''
        ''SUPER, 4, workspace, 4''
        ''SUPER, 5, workspace, 5''
        ''SUPER, 6, workspace, 6''
        ''SUPER, 7, workspace, 7''
        ''SUPER, 8, workspace, 8''
        ''SUPER, 9, workspace, 9''
        ''SUPER, 0, workspace, 10''

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        ''SUPER SHIFT, 1, movetoworkspace, 1''
        ''SUPER SHIFT, 2, movetoworkspace, 2''
        ''SUPER SHIFT, 3, movetoworkspace, 3''
        ''SUPER SHIFT, 4, movetoworkspace, 4''
        ''SUPER SHIFT, 5, movetoworkspace, 5''
        ''SUPER SHIFT, 6, movetoworkspace, 6''
        ''SUPER SHIFT, 7, movetoworkspace, 7''
        ''SUPER SHIFT, 8, movetoworkspace, 8''
        ''SUPER SHIFT, 9, movetoworkspace, 9''
        ''SUPER SHIFT, 0, movetoworkspace, 10''

        # Scroll through existing workspaces with mainMod + scroll
        ''SUPER, mouse_down, workspace, e+1''
        ''SUPER, mouse_up, workspace, e-1''

        #############################################################################
        # Custom keybinds
        # Show Rofi on SUPER-SPACE
        # ''SUPER, space, exec, fuzzel''
        ''SUPER, space, exec, rofi -show drun -show-icons''
        # Take a screenshot with the Print key''
        '', Print, exec, grim -g "$(slurp)" | wl-copy -t image/png''

        # Move to the previous / next workspace with SUPER-LEFT and SUPER-RIGHT
        ''SUPER      , right, workspace, e+1''
        ''SUPER      , left , workspace, e-1''
        ''SUPER SHIFT, right, movetoworkspace, e+1''
        ''SUPER SHIFT, left , movetoworkspace, e-1''
        ''SHIFT ALT, L, workspace, e+1''
        ''SHIFT ALT, H, workspace, e-1''

        # Lock the screen, send to swaylock and pause music
        ''SUPER, L, exec, swaylock''
        ''SUPER, L, exec, playerctl pause''

        # to switch between windows in a floating workspace
        ''SUPER ,Tab, cyclenext,          # change focus to another window''
        ''SUPER ,Tab, bringactivetotop,   # bring it to the top''
      ];
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        ''LCTRL SHIFT, mouse:272, movewindow''
        ''LCTRL SHIFT, mouse:273, resizewindow''
      ];

      exec-once = ''bash ~/.config/hypr/start.sh'';
    };
  };
}
