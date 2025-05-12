# NixOS Configuration
My personal NixOS configuration for all of my machines.

## Note
This configuration is split into two parts:
- This repo, the public stuff;
- And a private repo, with [`agenix`](https://github.com/ryantm/agenix)-encrypted secrets that I don't want to be public.

As a result, you can't just clone this configuration and run it.

You're welcome to use it as a reference for your own configuration, however I can't guarantee that this is a perfect example.

## Related Repositories
There are several related repositories that contain additional customisations:
- `suckless` tools (my custom forks):
	- [`dmenu`](https://github.com/zedseven/dmenu)
		- With additional changes here to run unavailable commands with `nix run`
	- [`dwm`](https://github.com/zedseven/dwm)
	- [`slock`](https://github.com/zedseven/slock)
	- [`st`](https://github.com/zedseven/st)
- [QMK firmware](https://github.com/zedseven/qmk_firmware) (for custom hardware-based keyboard layouts)
