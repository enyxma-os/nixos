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
        "/etc/NetworkManager/system-connections"
      ];
      description = "Directories to bind mount from persist";
    };
    files = mkOption {
      type = types.listOf types.str;
      default = [
        "/etc/machine-id"
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
      ++ (map (file: "L+ ${file} - - - - ${cfg.persistPath}${file}") cfg.files);
  };
}
