# NixOS Configuration
This is my personal NixOS configuration for all machines that I manage.

## Usage
1. Checkout the repo on the new machine.
2. Create a new directory under [`hosts`](hosts) with the new machine's name.
3. In that directory, create a `default.nix`.
4. Run `nixos-generate-config --show-hardware-config > hardware-configuration.nix` and put `hardware-configuration.nix` in that directory.
5. Import the necessary modules in `default.nix`.
6. Lastly, create `configuration.nix` in the root of the repo and import the host-specific `default.nix` that you just created:
```nix
{...}: {
  imports = [
    ./hosts/<HOSTNAME>
  ];
}
```
