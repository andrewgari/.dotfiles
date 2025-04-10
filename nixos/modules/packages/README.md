# NixOS Package Organization

This directory contains modular package definitions organized by category:

- `browsers.nix`: Web browsers and related tools
- `dev-tools.nix`: Development tools, programming languages, and IDEs
- `editors.nix`: Text editors and related tools
- `system-tools.nix`: System utilities and CLI tools
- `desktop-apps.nix`: Desktop applications and utilities
- `virtualization.nix`: Virtualization and container tools

## Adding New Packages

To add a new package, add it to the appropriate category file. If a package doesn't fit into any existing category, consider creating a new category file and adding it to `default.nix`.

## Usage

These packages are automatically included via the main `modules/default.nix` import.