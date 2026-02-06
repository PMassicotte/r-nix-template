{
  description = "A Nix-flake-based R development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.rNvim = {
    url = "github:R-nvim/R.nvim";
    flake = false;
  };

  outputs =
    { self, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowBroken = true;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        # Build nvimcom manually from R.nvim source
        nvimcom = final.rPackages.buildRPackage {
          name = "nvimcom";
          src = inputs.rNvim;
          sourceRoot = "source/nvimcom";

          buildInputs = with final; [
            R
            gcc
            gnumake
          ];

          meta = {
            description = "R.nvim communication package";
            homepage = "https://github.com/R-nvim/R.nvim";
            maintainers = [ ];
          };
        };

        # Shared R package list for both wrappers
        rPackageList = with final.rPackages; [
          cli
          cyclocomp
          fs
          httpgd
          languageserver
          lintr
          nvimcom
          renv
        ];

        # Create rWrapper with packages (for LSP and R.nvim)
        wrappedR = final.rWrapper.override { packages = rPackageList; };

        # Create radianWrapper with same packages (for interactive use)
        wrappedRadian = final.radianWrapper.override { packages = rPackageList; };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              wrappedR # R with packages for LSP
              wrappedRadian # radian with packages for interactive use
            ];
            
            shellHook = ''
              # Update renv.lock automatically when entering the shell
              echo "Updating renv.lock with current R packages..."
              ${pkgs.wrappedR}/bin/Rscript ${./generate-renv-lock.R} 2>/dev/null || true
            '';
          };
        }
      );

      templates = {
        default = {
          path = ./.;
          description = "R development environment with nvimcom and R.nvim integration";
          welcomeText = ''
            # R Nix Development Environment

            ## Getting started
            - Run `direnv allow` to activate the environment (if using direnv)
            - Customize R packages in flake.nix rPackageList
            - Enter the shell with `nix develop`

            ## What's included
            - R with languageserver, nvimcom, lintr, fs, and cli
            - radian (modern R console)
            - Configured for R.nvim integration
            - Pre-configured .lintr file with opinionated linting rules
          '';
        };
      };
    };
}
