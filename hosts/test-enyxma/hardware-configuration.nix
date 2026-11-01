{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
      kernelModules = [];
    };
    kernelModules = [];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ea904c39-f31f-4c92-919b-e5ea9cb575a3";
      fsType = "btrfs";
      options = ["subvol=@root" "compress=zstd" "noatime"];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/ea904c39-f31f-4c92-919b-e5ea9cb575a3";
      fsType = "btrfs";
      options = ["subvol=@home" "compress=zstd" "noatime"];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/ea904c39-f31f-4c92-919b-e5ea9cb575a3";
      fsType = "btrfs";
      options = ["subvol=@nix" "compress=zstd" "noatime"];
    };

    "/persist" = {
      device = "/dev/disk/by-uuid/ea904c39-f31f-4c92-919b-e5ea9cb575a3";
      fsType = "btrfs";
      options = ["subvol=@persist" "compress=zstd" "noatime"];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/40E4-ABED";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
