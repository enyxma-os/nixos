{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.enyxma.core = {
    enable = mkEnableOption "Enyxma Core Base System";
    timeZone = mkOption {
      type = types.str;
      default = "UTC";
      description = "Sistem saat dilimi.";
    };
    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Varsayılan sistem dili.";
    };
  };

  config = mkIf config.enyxma.core.enable {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = mkDefault true;
      warn-dirty = mkDefault false;
      trusted-users = mkDefault ["root" "@wheel"];
    };

    zramSwap.enable = mkDefault true;

    nix.gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 14d";
    };

    time.timeZone = mkDefault config.enyxma.core.timeZone;
    i18n.defaultLocale = mkDefault config.enyxma.core.locale;

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      vim
      pciutils
      usbutils
      which
      htop
      btop
      tree
      psmisc
      just
      python3
      lua5_4
    ];
  };
}
