# A barebones machine configuration that only exists to generate SSH host keys for use with `agenix`.
# Generated host keys will be in `/etc/ssh/ssh_host_*` and should be backed up once they're generated.
# https://github.com/ryantm/agenix/issues/17#issuecomment-797174338
{home-manager, ...}: {
  imports = [
    home-manager.nixosModules.home-manager
    ../../modules
  ];

  custom = {
    user = {
      type = "minimal";
      shellPromptCharacter = "Φ";
      hashedPasswordFile = ./empty-password-hash;
    };
  };
}
