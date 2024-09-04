{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # deck@nixos > configuration.nix
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
    # deck@nixos > home.nix
    homeConfigurations."deck@nixos" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          home.username = "deck";
          home.homeDirectory = "/home/deck";
          home.stateVersion = "23.11";
          home.packages = with pkgs; [
            just
            direnv
            fastfetch
          ];
          programs.home-manager.enable = true;
        }
      ];
    };
    # deck@archinux > home.nix
    homeConfigurations."deck@archinux" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          home.username = "deck";
          home.homeDirectory = "/home/deck";
          home.stateVersion = "23.11";
          home.packages = with pkgs; [
            just
            direnv
            fastfetch
          ];
          programs.home-manager.enable = true;
        }
      ];
    };
    # deck@steamos > home.nix
    homeConfigurations."deck@steamos" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          home.username = "deck";
          home.homeDirectory = "/home/deck";
          home.stateVersion = "23.11";
          home.packages = with pkgs; [
            just
            direnv
            fastfetch
          ];
          programs.home-manager.enable = true;
        }
      ];
    };
    # deck@POAN23090675 > home.nix
    homeConfigurations."deck@POAN23090675" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          home.username = "deck";
          home.homeDirectory = "/home/deck";
          home.stateVersion = "23.11";
          home.packages = with pkgs; [
            just
            direnv
            fastfetch
            wget
            which
          ];
          programs.home-manager.enable = true;
        }
      ];
    };
  };
}
