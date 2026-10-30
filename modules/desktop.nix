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
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # UPower ve Bluetooth arka plan servisleri (Enyxma Shell gereksinimleri)
    services.upower.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = ["hyprland" "gtk"];
    };

    # Enyxma Shell ve Hyprland masaüstü çalışma zamanı bağımlılıkları
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
      kitty
      foot
    ];

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
