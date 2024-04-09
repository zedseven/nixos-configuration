# Used during installation.
# https://mdleom.com/blog/2021/03/09/nixos-oracle/
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # this will work only under qemu, uncomment next line for full image
    # <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    <nixpkgs/nixos/modules/installer/netboot/netboot.nix>
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  # stripped down version of https://github.com/cleverca22/nix-tests/tree/master/kexec
  system.build = rec {
    image = pkgs.runCommand "image" {buildInputs = [pkgs.nukeReferences];} ''
      mkdir $out
      cp ${config.system.build.kernel}/Image $out/kernel
      cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
      nuke-refs $out/kernel
    '';
    kexec_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
        #!${pkgs.stdenv.shell}
        set -e
        ${pkgs.kexectools}/bin/kexec -l ${image}/kernel --initrd=${image}/initrd --append="init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
        sync
        echo "executing kernel, filesystems will be improperly umounted"
        ${pkgs.kexectools}/bin/kexec -e
      '';
    };
    kexec_tarball = pkgs.callPackage <nixpkgs/nixos/lib/make-system-tarball.nix> {
      storeContents = [
        {
          object = config.system.build.kexec_script;
          symlink = "/kexec_nixos";
        }
      ];
      contents = [];
    };
  };

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
    ];
    kernelParams = [
      "panic=30"
      "boot.panic_on_fail" # reboot the machine upon fatal boot issues
      "console=ttyS0" # enable serial console
      "console=tty1"
    ];
    kernel.sysctl."vm.overcommit_memory" = "1";

    supportedFilesystems = ["zfs"];
  };

  environment = {
    systemPackages = with pkgs; [cryptsetup];
    variables.GC_INITIAL_HEAP_SIZE = "1M";
  };

  networking = {
    hostName = "kexec";
    hostId = "01234567"; # For ZFS
  };

  services = {
    getty.autologinUser = "root";
    openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };
  };

  users.users.root.openssh.authorizedKeys.keys = ["<public-key>"];
}
