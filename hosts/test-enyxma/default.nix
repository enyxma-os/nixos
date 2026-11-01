{
  imports = [
    ./hardware-configuration.nix
  ];

  # Önyükleyici ve Başlangıç Yapılandırması
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Btrfs Root Rollback: Impermanence Stage 1 Systemd
    initrd = {
      supportedFilesystems = ["btrfs"];
      systemd.services.rollback = {
        description = "Rollback Btrfs root subvolume to pristine blank state";
        wantedBy = ["initrd.target"];
        after = ["initrd-root-device.target"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
            mkdir -p /btrfs_tmp
            mount -o subvolid=5 /dev/disk/by-uuid/ea904c39-f31f-4c92-919b-e5ea9cb575a3 /btrfs_tmp
            if [ -e /btrfs_tmp/@root ]; then
              btrfs subvolume list -o /btrfs_tmp/@root | cut -f9- -d' ' | while read -r subvol; do
                btrfs subvolume delete "/btrfs_tmp/$subvol" || true
              done
              if [ ! -e /btrfs_tmp/@root-blank ]; then
            btrfs subvolume snapshot -r /btrfs_tmp/@root /btrfs_tmp/@root-blank
          fi
              btrfs subvolume delete /btrfs_tmp/@root
            fi
            btrfs subvolume snapshot /btrfs_tmp/@root-blank /btrfs_tmp/@root
            umount /btrfs_tmp
            rmdir /btrfs_tmp
        '';
      };
    };
  };

  # Makine Adı
  networking.hostName = "test-enyxma";

  # Kullanıcı Tanımları: void ve root güvenli hash ile yapılandırıldı
  users.users = {
    void = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
      hashedPassword = "$6$uP5VDNH2QMG14JFl$BGju.dvUCCLqXvTK4oxGh6DXiK.UwNOI9h6jxwK.vBaJ0l5aFgSbHhar6aRnh4ezKvO4ewarfrE8HVi08Zyef/";
    };
    root.hashedPassword = "$6$uP5VDNH2QMG14JFl$BGju.dvUCCLqXvTK4oxGh6DXiK.UwNOI9h6jxwK.vBaJ0l5aFgSbHhar6aRnh4ezKvO4ewarfrE8HVi08Zyef/";
  };

  services = {
    # SSH Servisi: Uzaktan yönetim için açık
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };

    # QEMU Konuk Ajanı
    qemuGuest.enable = true;
  };

  # Enyxma OS Lego Katmanı 1 & 2
  enyxma = {
    core.enable = true;
    security.enable = true;
    network.enable = true;
    audio.enable = true;
    hardware.enable = true;
    persistence.enable = true;

    # Katman 2: Masaüstü ve Kabuk
    desktop.enable = true;
    desktop.hyprland.enable = true;
    shell.enable = true;
  };

  system.stateVersion = "26.05";
}
