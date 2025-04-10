{
  description = "NixOS configuration for Andrew Gari";

  # Allow working in a dirty git tree
  nixConfig = {
    allow-dirty = true;
  };

  inputs = {
    # Main channels
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager for dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Configure unstable channel
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      
      # Create an overlay to make unstable packages available
      overlay-unstable = final: prev: {
        unstable = pkgs-unstable;
      };
      
      # Configure pkgs instance with allowUnfree
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [ overlay-unstable ];
      };

      # Create specialArgs to pass to modules
      specialArgs = {
        inherit pkgs-unstable;
        unstable = pkgs-unstable;
      };

    in {
      nixosConfigurations = {
        # Framework 13 AMD laptop configuration
        laptop = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            # Base system configuration
            ./hosts/laptop
            
            # Framework hardware support
            nixos-hardware.nixosModules.framework-13-7040-amd
            
            # Common modules
            ./modules
            
            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.andrewgari = {
                imports = [ ./home.nix ];
                home.stateVersion = "24.11";
              };
              home-manager.backupFileExtension = "backup";
            }

            # Global system settings
            {
              nixpkgs.config.allowUnfree = true;
              programs.zsh.enable = true;
              
              # Nix settings
              nix = {
                package = pkgs.nixVersions.stable;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
                
                # Garbage collection
                gc = {
                  automatic = true;
                  dates = "weekly";
                  options = "--delete-older-than 14d";
                };
                
                # Optimize store
                settings.auto-optimise-store = true;
              };
            }
          ];
        };
      };
    };
}