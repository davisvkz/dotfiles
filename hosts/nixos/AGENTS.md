# NIXOS HOST CONFIGURATION

**Generated:** 2025-12-31

## OVERVIEW
Primary NixOS system configuration for host 'nixos' with BSPWM, Docker, Steam, and development tools.

## STRUCTURE
```
hosts/nixos/
├── configuration.nix        # Main system config
├── hardware-configuration.nix  # Auto-generated hardware
├── home.nix                # Home-manager user config
├── programs.nix            # System packages
├── imports.nix             # System module imports
├── hm-imports.nix          # Home-manager imports
├── my-hardware.nix         # Custom hardware (unused)
└── config/.zshrc           # Shell config
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| System services | configuration.nix | Docker, Steam, Bluetooth |
| User management | configuration.nix | davisvkz user, groups |
| Display/WM | configuration.nix | SDDM + BSPWM |
| Networking | configuration.nix | DNS, NetworkManager |
| Fonts | configuration.nix | Noto, Fira Code, emoji |
| Locale | configuration.nix | Brazil timezone/keyboard |
| System packages | programs.nix | Core system packages |
| Home config | home.nix | User-specific settings |

## CONVENTIONS
- Mixed DNS servers (Cloudflare + Google)
- Brazilian locale (pt_BR) with English system
- Docker with custom DNS configuration
- Steam firewall rules enabled
- Neovim as system-wide EDITOR

## ANTI-PATTERNS
- .zshrc managed directly instead of via home-manager
- my-hardware.nix unused but present