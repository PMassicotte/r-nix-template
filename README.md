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
nix flake update # update dependencies if needed
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

## Building Quarto with nix

Use this GH Action workflow to render and publish your Quarto site to GitHub Pages:

```yml
on:
  workflow_dispatch:
  push:
    branches:
      - main

name: Quarto Publish

jobs:
  build-deploy:
    runs-on: ubuntu-24.04
    permissions:
      contents: write
    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main

      - name: Setup Nix cache
        uses: DeterminateSystems/magic-nix-cache-action@main

      - name: Configure git
        run: |
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"

      - name: Render and Publish
        run: |
          nix develop --command quarto publish gh-pages index.qmd --no-browser --no-prompt
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
