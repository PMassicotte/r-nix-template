# nix-templates

A collection of Nix flake templates for reproducible development environments.

## Prerequisites

- Nix with flakes enabled
- (Optional) direnv for automatic environment activation

## Available templates

### `r-project` — R development environment

R environment with R.nvim and Neovim integration.

**Includes:** R, arf, jarl, httpgd, data.table

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

### Working on existing (non-flake) Rust projects

If you fork a project that doesn't use Nix, you can still use this template's dev environment without polluting the upstream repo.

1. Copy `flake.nix` and `.envrc` from this template into the project root.
2. Exclude them from git using your local gitignore (so they never appear in your PR):

```bash
echo "flake.nix" >>.git/info/exclude
echo "flake.lock" >>.git/info/exclude
echo ".envrc" >>.git/info/exclude
```

3. Activate the environment:

```bash
direnv allow
# or
nix develop
```

The Rust toolchain is now available and `cargo` will use the project's own `Cargo.toml` as usual.

---

## Common to all templates

After `nix flake init`:

```bash
direnv allow # activate automatically with direnv (recommended)
# or
nix develop # enter the shell manually
```

Run `nix flake update` periodically to update pinned dependencies.
