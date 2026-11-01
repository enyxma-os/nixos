{
  imports = [
    ./hardware-configuration.nix
  ];

  # Önyükleyici
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Makine Adı
  networking.hostName = "test-enyxma";

  # Kullanıcı Tanımları (void:1, root:1)
  users.users = {
    void = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
      initialPassword = "1";
    };
    root.initialPassword = "1";
  };

  # SSH Servisi (Uzaktan yönetim için açık)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # QEMU Konuk Ajanı
  services.qemuGuest.enable = true;

  # Enyxma OS Lego Katmanı 1 & 2
  enyxma = {
    core.enable = true;
    security.enable = true;
    network.enable = true;
    audio.enable = true;

    # Katman 2: Masaüstü ve Kabuk
    desktop.enable = true;
    desktop.hyprland.enable = true;
    shell.enable = true;
  };

  system.stateVersion = "26.05";
}
