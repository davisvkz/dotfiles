# NIXOS CONFIGURATION KNOWLEDGE BASE

**Generated:** 2025-12-31
**Commit:** flake-based
**Branch:** main

## OVERVIEW
Personal NixOS flake configuration with home-manager integration, BSPWM window manager, and development tools.

## STRUCTURE
```
./
├── flake.nix              # Main flake definition
├── flake.lock             # Input pins
├── alejandra.toml         # Nix formatter (tabs)
├── hosts/                 # Machine-specific configs
│   └── nixos/            # Primary host configuration
├── modules/              # Shared system modules
│   └── system/           # System-level modules
└── hm-modules/           # Home-manager modules
    └── programs/         # User program modules
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| System packages | hosts/nixos/programs.nix | Core system packages |
| User config | hosts/nixos/home.nix | Home-manager setup |
| Hardware config | hosts/nixos/hardware-configuration.nix | Auto-generated |
| Nix settings | modules/system/nix.nix | Experimental features |
| Shared modules | modules/, hm-modules/ | Reusable configurations |

## CONVENTIONS
- **Indentation**: Tabs (alejandra.toml)
- **Flake inputs**: nixpkgs-unstable + stable channel
- **User**: davisvkz (defined in flake.nix)
- **Shell**: zsh
- **Editor**: neovim (system-wide EDITOR)

## ANTI-PATTERNS (THIS PROJECT)
- No documented anti-patterns found

## UNIQUE STYLES
- Custom import aggregation (imports.nix, hm-imports.nix)
- Separate programs.nix module under hosts/
- Top-level hm-modules/ directory structure
- Mixed DNS configuration (1.1.1.1, 8.8.8.8, etc.)

## COMMANDS
```bash
# Rebuild system
sudo nixos-rebuild switch --flake .

# Rebuild home config
home-manager switch --flake .

# Check flake
nix flake check

# Format Nix files
alejandra .
```

## NOTES
- Steam enabled with firewall openings
- Docker configured with custom DNS
- Waydroid and Flatpak enabled
- Brazilian locale/keyboard layout
- No CI/CD workflows (standard for config repos)