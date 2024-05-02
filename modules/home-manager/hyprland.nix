{ ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hyprland;
in
{
  options = {
    hyprland = {
      enable = lib.mkEnableOption "Hyprland" // {
        default = true;
      };

      monitors = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption { type = lib.types.str; };
              width = lib.mkOption {
                type = lib.types.int;
                default = 1920;
              };
              height = lib.mkOption {
                type = lib.types.int;
                default = 1080;
              };
              refreshRate = lib.mkOption {
                type = lib.types.float;
                default = 60;
              };
              x = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };
              y = lib.mkOption {
                type = lib.types.int;
                default = 0;
              };
              scale = lib.mkOption { default = "auto"; };
              enable = lib.mkOption { type = lib.types.bool; };
            };
          }
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      settings =
        let
          modKey = "SUPER";
          terminal = "${pkgs.alacritty}/bin/alacritty";
          launcher = "${pkgs.rofi-wayland}/bin/rofi -show drun";
          fileManager = "${pkgs.gnome.nautilus}/bin/nautilus";
          browser = "${pkgs.brave}/bin/brave";
          menuBar = "${pkgs.waybar}/bin/waybar";
          screenshot = "${pkgs.grimblast}/bin/grimblast";
          brightness = "${pkgs.brightnessctl}/bin/brightnessctl";
          media = "${pkgs.playerctl}/bin/playerctl";

          monitor = builtins.map (
            m:
            let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
            in
            "${m.name}, ${if m.enable then "${resolution}, ${position}, ${toString m.scale}" else "disable"}"
          ) (cfg.monitors);
        in
        {
          inherit monitor;
          general = {
            border_size = 2;
            gaps_in = 4;
            gaps_out = 8;
            layout = "dwindle";
            resize_on_border = true;
          };
          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              xray = true;
            };
          };
          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
          input = {
            touchpad = {
              natural_scroll = true;
              scroll_factor = 0.5;
            };
          };
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 4;
          };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            force_split = 2;
          };
          master = {
            new_is_master = false;
          };
          xwayland = {
            force_zero_scaling = true;
          };
          env = [ "XCURSOR_SIZE, 24" ];
          exec-once = [
            # Wallpaper
            "${pkgs.swww}/bin/swww-daemon"
            "${pkgs.swww}/bin/swww img ${/home/${config.username}/dotfiles/assets/wallpaper.png} -t none"

            menuBar
          ];
          bind = [
            "${modKey}, C, killactive,"
            "${modKey}, V, togglefloating,"
            "${modKey}, P, fullscreen, 1"
            "${modKey}, T, exec, ${terminal}"
            "${modKey}, F, exec, ${fileManager}"
            "${modKey}, R, exec, ${launcher}"
            "${modKey}, B, exec, ${browser}"
            "${modKey}, W, exec, pkill waybar || ${menuBar}"

            # Move focus
            "${modKey}, left, movefocus, l"
            "${modKey}, right, movefocus, r"
            "${modKey}, up, movefocus, u"
            "${modKey}, down, movefocus, d"
            "${modKey}, H, movefocus, l"
            "${modKey}, L, movefocus, r"
            "${modKey}, K, movefocus, u"
            "${modKey}, J, movefocus, d"
            # Move window
            "${modKey}_SHIFT, left, movewindow, l"
            "${modKey}_SHIFT, right, movewindow, r"
            "${modKey}_SHIFT, up, movewindow, u"
            "${modKey}_SHIFT, down, movewindow, d"
            "${modKey}_SHIFT, H, movewindow, l"
            "${modKey}_SHIFT, L, movewindow, r"
            "${modKey}_SHIFT, K, movewindow, u"
            "${modKey}_SHIFT, J, movewindow, d"

            # Switch workspaces with mainMod + [0-9]
            "${modKey}, 1, workspace, 1"
            "${modKey}, 2, workspace, 2"
            "${modKey}, 3, workspace, 3"
            "${modKey}, 4, workspace, 4"
            "${modKey}, 5, workspace, 5"
            "${modKey}, 6, workspace, 6"
            "${modKey}, 7, workspace, 7"
            "${modKey}, 8, workspace, 8"
            "${modKey}, 9, workspace, 9"
            "${modKey}, 0, workspace, 10"
            "${modKey}, S, togglespecialworkspace, special:scratchpad"

            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            "${modKey}_SHIFT, 1, movetoworkspace, 1"
            "${modKey}_SHIFT, 2, movetoworkspace, 2"
            "${modKey}_SHIFT, 3, movetoworkspace, 3"
            "${modKey}_SHIFT, 4, movetoworkspace, 4"
            "${modKey}_SHIFT, 5, movetoworkspace, 5"
            "${modKey}_SHIFT, 6, movetoworkspace, 6"
            "${modKey}_SHIFT, 7, movetoworkspace, 7"
            "${modKey}_SHIFT, 8, movetoworkspace, 8"
            "${modKey}_SHIFT, 9, movetoworkspace, 9"
            "${modKey}_SHIFT, 0, movetoworkspace, 10"
            "${modKey}_SHIFT, S, movetoworkspace, special:scratchpad"

            # Scroll through existing workspaces with mainMod + scroll
            "${modKey}, mouse_down, workspace, e+1"
            "${modKey}, mouse_up, workspace, e-1"

            # Screenshot
            ", Print, exec, ${screenshot} --cursor copy area"
          ];
          # Mouse
          bindm = [
            # Move windows with mainMod + LMB and dragging
            "${modKey}, mouse:272, movewindow"
          ];
          # Repeat - Locked
          bindel = [
            # Volume
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- --limit 1.0"
            "${modKey}, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ --limit 1.0"
            "${modKey}, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- --limit 1.0"

            # Brightness
            ", XF86MonBrightnessUp, exec, ${brightness} set 5%+"
            ", XF86MonBrightnessDown, exec, ${brightness} set 5%-"
          ];
          # Locked
          bindl = [
            # Mute Volume        
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

            # Media
            ", XF86AudioPlay, exec, ${media} play-pause"
            ", XF86AudioPrev, exec, ${media} previous"
            ", XF86AudioNext, exec, ${media} next"
            ", XF86AudioNext, exec, ${media} next"
            ", XF86AudioStop, exec, ${media} stop"
          ];
        };
    };
  };
}