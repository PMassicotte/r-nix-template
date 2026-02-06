# R Nix Development Environment

A Nix-flake-based R development environment with nvimcom and R.nvim integration.

## Prerequisites

- Nix with flakes enabled
- (Optional) direnv for automatic environment activation

## Quick Start

### Using direnv (recommended)

If you have direnv installed:

```bash
direnv allow
```

The environment will activate automatically when you enter the directory.

### Using nix develop

```bash
nix develop
```

This will drop you into a shell with R and all packages available.

## What's Included

- **R** with the following packages:
  - languageserver (for LSP support)
  - nvimcom (for R.nvim integration)
- **radian** - A modern R console with syntax highlighting and auto-completion

## Customization

To add more R packages, edit `flake.nix` and modify the `rPackageList`:

```nix
rPackageList = with final.rPackages; [
  languageserver
  nvimcom
  # Add your packages here
];
```

Then run:

```bash
nix flake update              # update dependencies if needed
nix run .#update-renv-lock    # update renv.lock to match Nix packages
nix develop                   # or just reload if using direnv
```

### Updating renv.lock

After running `nix flake update` or modifying packages in `flake.nix`, update the `renv.lock` file to match:

```bash
nix run .#update-renv-lock
```

This maintains compatibility with `renv`-based workflows by keeping `renv.lock` synchronized with your Nix environment.


## Usage

### Start R

```bash
R
```

### Start radian (enhanced R console)

```bash
radian
```

## Using as a Template

You can use this as a template for new R projects:

```bash
nix flake init -t github:PMassicotte/r-nix-template
```
