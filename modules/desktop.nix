{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.enyxma.desktop = {
    enable = mkEnableOption "Enyxma Wayland Desktop Infrastructure";
  };

  config = mkIf config.enyxma.desktop.enable {
    # Bluetooth arka plan servisi
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.sessionVariables = {
      QS_CONFIG_PATH = "$HOME/.local/share/enyxma-shell/runtime/shell.qml";
    };

    # Enyxma Shell ve masaüstü çalışma zamanı ek bağımlılıkları
    environment.systemPackages = with pkgs; [
      quickshell
      awww
      matugen
      brightnessctl
      playerctl
      pamixer
      cliphist
      wl-clipboard
      libnotify
      grim
      slurp
      thunar
      thunar-volman
      librewolf
      hyprlock
      hypridle
      kdePackages.breeze
      adwaita-icon-theme
      (sddm-astronaut.override {
        themeConfig = {
          Background = "Backgrounds/astronaut.png";
          DimBackground = "0.4";
          CropBackground = "true";

          PartialBlur = "true";
          HaveFormBackground = "true";
          FormPosition = "center";
          RoundCorners = "12";

          HideVirtualKeyboard = "true";

          HeaderTextColor = "#c0caf5";
          DateTextColor = "#a9b1d6";
          TimeTextColor = "#7aa2f7";

          BackgroundColor = "#1a1b26";
          DimBackgroundColor = "#1a1b26";
          FormBackgroundColor = "#1f2335";

          LoginFieldBackgroundColor = "#24283b";
          PasswordFieldBackgroundColor = "#24283b";
          LoginFieldTextColor = "#c0caf5";
          PasswordFieldTextColor = "#c0caf5";
          UserIconColor = "#7aa2f7";
          PasswordIconColor = "#7aa2f7";
          PlaceholderTextColor = "#565f89";
          WarningColor = "#292e42";

          LoginButtonBackgroundColor = "#7aa2f7";
          LoginButtonTextColor = "#1a1b26";

          SystemButtonsIconsColor = "#c0caf5";
          SessionButtonTextColor = "#c0caf5";

          DropdownBackgroundColor = "#1f2335";
          DropdownSelectedBackgroundColor = "#292e42";
          DropdownTextColor = "#c0caf5";

          HighlightBackgroundColor = "#292e42";
          HighlightBorderColor = "#7aa2f7";
          HighlightTextColor = "#7aa2f7";

          HoverUserIconColor = "#7dcfff";
          HoverPasswordIconColor = "#7dcfff";
          HoverSystemButtonsIconsColor = "#7dcfff";
          HoverSessionButtonTextColor = "#7dcfff";

          ForceLastUser = "true";
          PasswordFocus = "true";
          HideCompletePassword = "true";
        };
      })
    ];

    services = {
      upower.enable = true;
      xserver.enable = true;
      displayManager = {
        defaultSession = "hyprland-uwsm";
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "sddm-astronaut-theme";
          extraPackages = with pkgs.kdePackages; [
            qtmultimedia
            qtsvg
          ];
          settings.Theme = {
            CursorTheme = "breeze_cursors";
            CursorSize = "24";
          };
        };
      };
    };

    security.pam.services.hyprlock = {};

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        inter
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
      fontconfig.defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font"];
        sansSerif = ["Inter"];
        serif = ["Noto Serif"];
      };
    };
  };
}
