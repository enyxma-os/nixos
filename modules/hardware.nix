{
  config,
  lib,
  ...
}:
with lib; {
  options.enyxma.hardware = {
    enable = mkEnableOption "Enyxma Hardware and Storage Abstractions";
  };

  config = mkIf config.enyxma.hardware.enable {
    hardware.enableRedistributableFirmware = true;
  };
}
