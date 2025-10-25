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
  - tidyverse
- **radian** - A modern R console with syntax highlighting and auto-completion

## Customization

To add more R packages, edit `flake.nix` and modify the `rPackageList`:

```nix
rPackageList = with final.rPackages; [
  languageserver
  nvimcom
  tidyverse
  # Add your packages here
];
```

Then run:

```bash
nix flake update # if needed
nix develop      # or just reload if using direnv
```

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
