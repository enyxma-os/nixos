{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.enyxma.persistence;
in {
  options.enyxma.persistence = {
    enable = mkEnableOption "Enyxma Native Impermanence";
    persistPath = mkOption {
      type = types.str;
      default = "/persist";
      description = "Path to persistent storage subvolume";
    };
    directories = mkOption {
      type = types.listOf types.str;
      default = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/sddm"
        "/etc/NetworkManager/system-connections"
      ];
      description = "Directories to bind mount from persist";
    };
    files = mkOption {
      type = types.listOf types.str;
      default = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      description = "Files to link from persist";
    };
  };

  config = mkIf cfg.enable {
    fileSystems =
      (listToAttrs (map (dir: {
          name = dir;
          value = {
            device = "${cfg.persistPath}${dir}";
            fsType = "none";
            options = ["bind" "noexec" "nodev"];
            depends = [cfg.persistPath];
          };
        })
        cfg.directories))
      // {
        "${cfg.persistPath}" = {
          neededForBoot = true;
        };
      };

    systemd.tmpfiles.rules =
      (map (dir: "d ${cfg.persistPath}${dir} 0755 root root -") cfg.directories)
      ++ (map (file: "d ${cfg.persistPath}${builtins.dirOf file} 0755 root root -") cfg.files)
      ++ (map (file: "L+ ${file} - - - - ${cfg.persistPath}${file}") cfg.files);
  };
}
