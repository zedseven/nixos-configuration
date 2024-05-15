{
  config,
  pkgs,
  lib,
  inputs,
  system,
  isServer,
  ...
}: let
  cfg = config.custom.wireguard-vanity-addresses;
in {
  options.custom.wireguard-vanity-addresses = with lib; {
    enable = mkEnableOption "a service that runs indefinitely to find wireguard public keys with specific prefixes";
    outputPath = mkOption {
      description = mdDoc "The output file to write the results to. The results are appended, so the file will not be overwritten.";
      type = types.path;
    };
    prefixes = mkOption {
      description = mdDoc "The list of prefixes to search for.";
      type = types.listOf types.str;
    };
  };

  config = lib.mkIf cfg.enable (
    let
      wireguard-vanity-address = inputs.self.packages.${system}.wireguard-vanity-address.override {
        # This setting only works if the machine that builds the package is the same as the one that runs it, which is
        # not the case for servers
        optimiseForNativeCpu = !isServer;
      };

      prefixesList = lib.concatStringsSep " " cfg.prefixes;
      searchKeys = pkgs.writeShellScriptBin "search-keys" ''
        while :
        do
          ${wireguard-vanity-address}/bin/wireguard-vanity-address ${prefixesList} >> ${cfg.outputPath}
        done
      '';
    in {
      systemd.services."wireguard-vanity-addresses" = {
        enable = true;
        description = "wireguard-vanity-addresses";
        serviceConfig.ExecStart = "${searchKeys}/bin/search-keys";
      };
    }
  );
}
