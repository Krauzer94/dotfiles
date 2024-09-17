{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {
    nixpkgs,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # deck@nixos
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
    # nixos@nixos
    #nixosConfigurations."nixos@nixos" = nixpkgs.lib.nixosSystem {
    #  system = "x86_64-linux";
    #  modules = [
    #    # Raw configuration
    #  ];
    #};
  };
}
