{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.enyxma.core = {
    enable = mkEnableOption "Enyxma Core Base System";
  };

  config = mkIf config.enyxma.core.enable {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      warn-dirty = false;
      trusted-users = ["root" "@wheel"];
    };

    zramSwap.enable = true;

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    time.timeZone = "Europe/Istanbul";
    i18n.defaultLocale = "en_US.UTF-8";

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
