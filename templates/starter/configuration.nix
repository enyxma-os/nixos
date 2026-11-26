{lib, ...}: {
  # Hedef makinede `sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix`
  # komutuyla olusturulan donanim yapilandirmasini iceri alin:
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = lib.mkDefault "enyxma-host";

  enyxma = {
    core = {
      enable = true;
      timeZone = lib.mkDefault "UTC";
      locale = lib.mkDefault "en_US.UTF-8";
    };
    security.enable = true;
    network.enable = true;
    audio.enable = true;
    desktop = {
      enable = true;
      hyprland.enable = true;
    };
    shell.enable = true;
  };

  system.stateVersion = "25.05";
}

