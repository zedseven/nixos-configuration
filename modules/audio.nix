{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.persistentAudioSettings;
in {
  options.services.persistentAudioSettings = with lib; {
    enable = mkEnableOption "persistent-audio-settings";
    alsaDirPath = mkOption {
      description = mdDoc "The path to the directory where ALSA should store its data.";
      type = types.str;
      default = "/var/lib/alsa";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."persistent-audio-settings" = {
      enable = true;
      description = "persistent-audio-settings";
      after = ["sound.target"];
      serviceConfig = {
        RemainAfterExit = true;
        ExecStart = "${pkgs.alsa-utils}/bin/alsactl restore --config-dir=\"${cfg.alsaDirPath}\" --file=\"${cfg.alsaDirPath}/asound.state\"";
        ExecStop = "${pkgs.alsa-utils}/bin/alsactl store --config-dir=\"${cfg.alsaDirPath}\" --file=\"${cfg.alsaDirPath}/asound.state\"";
      };
      wantedBy = ["graphical.target"];
    };
  };
}
