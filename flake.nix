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
      overlays.default = final: prev: {
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
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          rPackageList = with pkgs.rPackages; [
            cli
            cyclocomp
            fs
            httpgd
            languageserver
            lintr
            pkgs.nvimcom
          ];
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              (pkgs.rWrapper.override { packages = rPackageList; }) # R with packages for LSP
              (pkgs.radianWrapper.override { packages = rPackageList; }) # radian with packages for interactive use
            ];
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
