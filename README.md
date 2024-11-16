# nixos-iso

Place your public ssh key(s) into `./keys`

To build the ISO for the architecture of your current machine, execute `nix run .`
For alternative architectures, execute `nix run .#${architecture}`, eg `nix run .#aarch64-linux`

The resulting ISO will be available under `./result/iso/*.iso`
