{
  description = "A Nix-flake-based R development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.rNvim = {
    url = "github:R-nvim/R.nvim";
    flake = false;
  };

  # Track arf on main; run `nix flake update arf` (or `nix flake update`) to upgrade
  inputs.arf = {
    url = "github:eitsupi/arf";
    flake = false;
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;
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
        # Build arf (modern Rust-based R console) from the flake input.
        # cargoLock reads Cargo.lock directly from the source so no manual hash updates are needed.
        # To upgrade: nix flake update arf  (or just: nix flake update)
        arf = final.rustPlatform.buildRustPackage {
          pname = "arf";
          version = inputs.arf.shortRev or "unstable";

          src = inputs.arf;

          cargoLock = {
            lockFile = "${inputs.arf}/Cargo.lock";
            # Git deps not on crates.io need explicit hashes. If `nix flake update arf`
            # errors with "No hash found for X-Y.Z": set that key to lib.fakeHash,
            # run `nix develop`, then paste the "got: sha256-..." value here.
            outputHashes = {
              "crossterm-0.29.0" = "sha256-SLgsOq875vQXnKxoAfG5PvEegpRJrxXCD2CV1jyI9TQ=";
              "rd-parser-0.1.0" = "sha256-gb3Q05D+qBWcjLnR5INMb5mn910KsSt5Tk/PW8EnUps=";
              "rd2qmd-core-0.1.0" = "sha256-gb3Q05D+qBWcjLnR5INMb5mn910KsSt5Tk/PW8EnUps=";
              "rd2qmd-mdast-0.1.0" = "sha256-gb3Q05D+qBWcjLnR5INMb5mn910KsSt5Tk/PW8EnUps=";
              "tree-sitter-r-1.2.0" = "sha256-H4iK2p4xXjP6gGrOP/qpHQCiO3Jyy0jmb8u29RM0sBg=";
            };
          };

          # Two cd/tilde tests fail in the Nix sandbox (no $HOME), skip them
          doCheck = false;

          buildInputs = with final; lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];
          nativeBuildInputs = with final; [ pkg-config ];

          meta = {
            description = "A modern Rust-based R console with fuzzy history, tree-sitter highlighting, and vi/emacs modes";
            homepage = "https://github.com/eitsupi/arf";
            license = lib.licenses.mit;
            mainProgram = "arf";
          };
        };

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
            packages = with pkgs; [
              wrappedR # R with packages for LSP
              wrappedRadian # radian with packages for interactive use
              arf # modern Rust-based R console
            ];

            shellHook = ''
              export R_HOME=$(R RHOME)
              export R_LIBS_SITE=$(grep -oP "'/nix/store/[^']+/library'" "$(command -v R)" | tr -d "'" | sort -u | paste -sd: -)
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
            - arf (modern Rust-based R console)
            - Configured for R.nvim integration
            - Pre-configured .lintr file with opinionated linting rules
          '';
        };
      };
    };
}
