{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.enyxma.audio = {
    enable = mkEnableOption "Enyxma Low-Latency Audio Stack";
  };

  config = mkIf config.enyxma.audio.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 64;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 512;
        };
      };

      extraConfig.pipewire-pulse."92-low-latency" = {
        "pulse.properties" = {
          "pulse.min.req" = "32/48000";
          "pulse.default.req" = "64/48000";
          "pulse.max.req" = "512/48000";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pulseaudio
      pavucontrol
    ];
  };
}
