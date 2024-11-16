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
              { pkgs, modulesPath, ... }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
                console.keyMap = "de_CH-latin1";
                services.openssh.settings = {
                  PermitRootLogin = lib.mkForce "prohibit-password";
                  PasswordAuthentication = false;
                  PubkeyAuthentication = true;
                };
                users.users = lib.listToAttrs (
                  map
                    (name: {
                      inherit name;
                      value = {
                        # nixos
                        hashedPassword = "$y$j9T$KEl2fuMvRTfDRdsCfEfEE/$7llFW7YP6XEPvJu4yxiJUD9WPI6RsI8.wd3oowNA1/6";
                        initialHashedPassword = lib.mkForce null;
                        openssh.authorizedKeys.keys = lib.mapAttrsToList (n: v: builtins.readFile ./keys/${n}) (
                          lib.filterAttrs (n: v: v == "regular" && !(lib.hasPrefix "." n)) (builtins.readDir ./keys)
                        );
                      };
                    })
                    [
                      "nixos"
                      "root"
                    ]
                );
                # environment.systemPackages = [ pkgs.gitMinimal ];
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
