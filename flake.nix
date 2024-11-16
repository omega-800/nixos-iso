{
  description = "Custom NixOS ISO image for deployments with nixos-anywhere";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "i686-linux"
        "aarch64-linux"
        "x86_64-linux"
      ];
      inherit (nixpkgs) lib;
    in
    {
      nixosConfigurations = lib.genAttrs systems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { modulesPath, ... }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
                console.keyMap = "de_CH-latin1";
                services.openssh.settings = {
                  PermitRootLogin = "yes";
                  PermitEmptyPasswords = "yes";
                };
              }
            )
          ];
        }
      );
      apps = lib.mapAttrs (system: v: rec {
        build-iso = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.writeShellScript "build-iso-for-${system}"
            "nix build .#nixosConfigurations.${system}.config.system.build.isoImage"
          }";
        };
        default = build-iso;
      }) self.nixosConfigurations;
    };
}
