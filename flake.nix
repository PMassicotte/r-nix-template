{
  description = "Nix flake templates";

  outputs = { self }: {
    templates = {
      r-project = {
        path = ./templates/r-project;
        description = "R development environment with R.nvim integration";
        welcomeText = ''
          # R Nix Development Environment

          ## Getting started
          - Run `direnv allow` to activate the environment (if using direnv)
          - Enter the shell with `nix develop`

          ## Package layout
          - `ideRPackages`     — editor support (httpgd, data.table); rarely changed
          - `projectRPackages` — analysis packages (cli, fs); edit per project

          ## What's included
          - R with httpgd, data.table, cli, and fs
          - radian (modern R console)
          - arf (modern Rust-based R console)
          - jarl (fast R linter)
          - nvimcom auto-built by R.nvim into .r-libs/ on first use
        '';
      };

      rust-cli = {
        path = ./templates/rust-cli;
        description = "Rust CLI with crane and rust-overlay";
        welcomeText = ''
          # Rust CLI Nix Template

          ## Getting started
          - Edit `Cargo.toml` and rename the package from `my-cli` to your project name
          - Run `nix develop` to enter the dev shell (cargo, clippy, rustfmt, rust-analyzer included)
          - Run `nix build` to compile
          - Run `nix run` to run directly
          - Run `nix profile install .#` to install the binary to your PATH

          ## Updating dependencies
          - Add Cargo deps to `Cargo.toml` as normal
          - Run `nix flake update` to update the Rust toolchain and crane
        '';
      };
    };
  };
}
