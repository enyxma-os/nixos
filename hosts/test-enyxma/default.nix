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

  services = {
    # SSH Servisi (Uzaktan yönetim için açık)
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };

    # QEMU Konuk Ajanı
    qemuGuest.enable = true;

    # Greetd Otomatik Oturum (Açılışta doğrudan Hyprland başlar)
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "void";
        };
        default_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "void";
        };
      };
    };
  };

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
