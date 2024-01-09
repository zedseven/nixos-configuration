# NixOS Configuration
My personal NixOS configuration for all of my machines.

## Note
This configuration is split into two parts:
- This repo, the public stuff;
- And a private repo, with [`agenix`](https://github.com/ryantm/agenix)-encrypted secrets that I don't want to be public.

As a result, you can't just clone this configuration and run it.

You're welcome to use it as a reference for your own configuration, however I can't guarantee this is a perfect example.

## Related Repositories
There are several related repositories that contain additional customisations:
- `suckless` tools (my custom forks):
	- [`dmenu`](https://github.com/zedseven/dmenu)
	- [`dwm`](https://github.com/zedseven/dwm)
	- [`slock`](https://github.com/zedseven/slock)
	- [`st`](https://github.com/zedseven/st)
- [QMK firmware](https://github.com/zedseven/qmk_firmware) (for custom hardware-based keyboard layouts)

## Usage
1. Checkout the repo on the new machine.
2. Run the following to switch the machine config to the minimal install and generate SSH host keys:
	```bash
	sudo nixos-rebuild switch --flake '.#_install'
	```
3. Backup the generated SSH host keys at `/etc/ssh/ssh_host_*`.
4. Run the following and copy the `ssh-ed25519` value it outputs. This is the public key for the host:
	```bash
	ssh-keyscan localhost
	```
5. Add the public key to the private repository's `secrets.nix` file, add the system to the appropriate system
  groupings, and run the following:
	```bash
	agenix --rekey
	```
6. Add a new entry to [`flake.nix`](/flake.nix) with the new machine's name.
7. Create a new directory under [`hosts`](/hosts) with the same name as you used in the step above.
8. Run `nixos-generate-config --show-hardware-config > hardware-configuration.nix` and
  put `hardware-configuration.nix` in that directory.
9. In that directory, create a `default.nix` and configure it as necessary.
10. Run the following, where `<NEW_HOSTNAME>` is the new machine's name. After you've done it the first time,
  Nix will automatically use that hostname on subsequent rebuilds:
    ```bash
	sudo nixos-rebuild switch --flake '.#<NEW_HOSTNAME>'
	```
