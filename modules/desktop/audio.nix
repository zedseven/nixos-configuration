{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom.desktop.audio;
in {
  options.custom.desktop.audio = with lib; {
    persistentSettings = {
      enable = mkEnableOption "persistent audio settings";
      alsaDirPath = mkOption {
        description = mdDoc "The path to the directory where ALSA should store its data.";
        type = types.path;
        default = "/var/lib/alsa";
      };
    };
  };

  config = let
    stateFile = "${cfg.persistentSettings.alsaDirPath}/asound.state";
  in
    lib.mkIf cfg.persistentSettings.enable {
      systemd.services."persistent-audio-settings" = {
        enable = true;
        description = "persistent-audio-settings";
        after = ["sound.target"];
        serviceConfig = {
          RemainAfterExit = true;
          ExecStart = "-${pkgs.alsa-utils}/bin/alsactl restore --config-dir=\"${cfg.persistentSettings.alsaDirPath}\" --file=\"${stateFile}\"";
          ExecStop = "${pkgs.alsa-utils}/bin/alsactl store --config-dir=\"${cfg.persistentSettings.alsaDirPath}\" --file=\"${stateFile}\"";
        };
        wantedBy = ["graphical.target"];
      };
    };
}
