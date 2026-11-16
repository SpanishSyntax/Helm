{
  description = "FlightDeck (Helm) - Qt6 GUI controller and management cockpit for Hyprland and Caelestia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = fn:
      nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux (
        system: fn nixpkgs.legacyPackages.${system}
      );
  in {
    packages = forAllSystems (pkgs: rec {
      flightdeck = pkgs.callPackage ./nix {};
      helm = flightdeck;
      default = flightdeck;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          cmake
          ninja
          pkg-config
          qt6.qtbase
          qt6.qtdeclarative
          qt6.qtshadertools
          qt6.qtsvg
          hyprland
          lua5_4
          glib
          dconf
          xrdb
        ];
      };
    });

    homeManagerModules.default = {
      config,
      lib,
      pkgs,
      ...
    }:
      with lib; let
        pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        helmCfg = config.programs.helm;
        flightdeckCfg = config.programs.flightdeck;
        enabled = helmCfg.enable || flightdeckCfg.enable;
        activeCfg =
          if helmCfg.enable
          then helmCfg
          else flightdeckCfg;
      in {
        options.programs.helm = {
          enable = mkEnableOption "Helm (FlightDeck) - Qt6 GUI controller and management cockpit for Hyprland and Caelestia";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The Helm / FlightDeck package to use.";
          };
        };

        options.programs.flightdeck = {
          enable = mkEnableOption "Alias for programs.helm";
          package = mkOption {
            type = types.package;
            default = pkg;
            description = "The Helm / FlightDeck package to use.";
          };
        };

        config = mkIf enabled {
          home.packages = [activeCfg.package];
        };
      };

    homeModules.default = self.homeManagerModules.default;
  };
}
