{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.enyxma.security;
  blockedNpm = pkgs.writeShellScriptBin "npm" ''
    echo "HATA: npm kullanımı bu sistemde kesinlikle yasaktır. pnpm kullanınız." >&2
    echo "Kural referansı: CONSTITUTION.md Madde 2" >&2
    exit 1
  '';
  blockedNpx = pkgs.writeShellScriptBin "npx" ''
    echo "HATA: npx kullanımı bu sistemde kesinlikle yasaktır. pnpm dlx veya Nix derivation kullanınız." >&2
    echo "Kural referansı: CONSTITUTION.md Madde 2" >&2
    exit 1
  '';
in {
  options.enyxma.security = {
    enable = mkEnableOption "Enyxma Zero-Trust Security Baseline";
    banNpm = mkOption {
      type = types.bool;
      default = true;
      description = "Zero-trust policy to ban npm and npx binaries";
    };
    hardenedKernel = mkOption {
      type = types.bool;
      default = true;
      description = "Enable security hardening sysctl parameters";
    };
  };

  config = mkIf cfg.enable {
    security = {
      sudo.enable = true;
      polkit.enable = true;
    };

    boot.kernel.sysctl = mkIf cfg.hardenedKernel {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.printk" = "3 3 3 3";
      "kernel.unprivileged_bpf_disabled" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
    };

    environment.systemPackages = mkIf cfg.banNpm [
      blockedNpm
      blockedNpx
      pkgs.pnpm
    ];
  };
}
