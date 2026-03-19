# nix-templates

A collection of Nix flake templates for reproducible development environments.

## Prerequisites

- Nix with flakes enabled
- (Optional) direnv for automatic environment activation

## Available templates

### `r-project` — R development environment

R environment with R.nvim and Neovim integration.

**Includes:** R, radian, arf, jarl, httpgd, data.table

```bash
nix flake init -t github:PMassicotte/nix-templates#r-project
```

---

### `r-package-dev` — R package development

Full-featured environment for developing R packages with Nix reproducibility.

**Includes:** devtools, roxygen2, testthat, usethis, pkgdown, rcmdcheck, urlchecker, arf, jarl, httpgd

```bash
nix flake init -t github:PMassicotte/nix-templates#r-package-dev
```

---

### `rust-cli` — Rust CLI

Rust CLI project using crane (build) and rust-overlay (toolchain).

**Includes:** cargo, clippy, rustfmt, rust-analyzer (stable latest, pinned)

```bash
nix flake init -t github:PMassicotte/nix-templates#rust-cli
```

After init, rename the package in `Cargo.toml` from `my-cli` to your project name.

#### Commands

| Command                  | What it does                          |
| ------------------------ | ------------------------------------- |
| `nix build`              | Compile the project                   |
| `nix run`                | Build and run                         |
| `nix develop`            | Enter dev shell                       |
| `nix profile install .#` | Install binary to your PATH           |
| `nix flake update`       | Update all inputs (Rust, crane, etc.) |

---

## Common to all templates

After `nix flake init`:

```bash
direnv allow # activate automatically with direnv (recommended)
# or
nix develop # enter the shell manually
```

Run `nix flake update` periodically to update pinned dependencies.
