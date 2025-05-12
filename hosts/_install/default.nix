# A barebones machine configuration that only exists to generate SSH host keys for use with `agenix`.
# Generated host keys will be in `/etc/ssh/ssh_host_*` and should be backed up once they're generated.
# https://github.com/ryantm/agenix/issues/17#issuecomment-797174338
{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules
  ];

  # Hostnames must start with an alphanumeric character and cannot contain an underscore
  # https://en.wikipedia.org/wiki/Hostname#Syntax
  networking.hostName = "install";

  custom.user = {
    type = "minimal";
    shellPromptCharacter = "Φ";
    hashedPasswordFile = ./empty-password-hash;
  };
}
