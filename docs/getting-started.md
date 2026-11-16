# Getting Started

This guide explains how to install, configure, and operate Helm (FlightDeck) within Hyprland and Caelestia environments.

---

## Installation

Helm provides first-class installation packages across NixOS / Home Manager, Arch Linux AUR, and universal CMake source builds.

### Nix Flake & Home Manager

Helm is packaged with native Nix Flake outputs supporting `x86_64-linux` and `aarch64-linux`.

#### 1. Instant Execution via Flake
Run Helm directly without permanently installing it:
```bash
nix run github:SpanishSyntax/Helm
```

Or invoke specific CLI subcommands:
```bash
nix run github:SpanishSyntax/Helm -- reload
nix run github:SpanishSyntax/Helm -- doctor
```

#### 2. Adding to System Flake
Add Helm to your `flake.nix` inputs:

```nix
{
  description = "NixOS / Home Manager Fleet Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    helm = {
      url = "github:SpanishSyntax/Helm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, helm, ... }@inputs: {
    # NixOS / Home Manager configuration definitions
  };
}
```

#### 3. Home Manager Configuration
Import and enable the module in your Home Manager user profile:

```nix
{ inputs, pkgs, ... }: {
  imports = [
    inputs.helm.homeManagerModules.default
  ];

  programs.helm = {
    enable = true;
    # package = inputs.helm.packages.${pkgs.stdenv.hostPlatform.system}.default; # optional custom package
  };
}
```

> [!NOTE]
> `programs.flightdeck.enable = true;` is provided as an exact alias for `programs.helm.enable = true;`. Both `helm` and `flightdeck` binaries are symlinked in `$out/bin`.

---

### Arch Linux / AUR

On Arch Linux, EndeavourOS, or Caelestia-based Arch systems, install via your preferred AUR helper:

```bash
# Stable release (builds from source)
paru -S astra-flightdeck

# Precompiled binary (fast install)
paru -S astra-flightdeck-bin

# Development trunk (latest git commit)
paru -S astra-flightdeck-git
```

---

### Building from Source

#### Prerequisites

**Build Dependencies:**
- C++20 compliant compiler (`gcc` 11+ or `clang` 13+)
- `cmake` (>= 3.19)
- `ninja`
- `pkg-config`
- `qt6-base`, `qt6-declarative`, `qt6-shadertools`, `qt6-svg` (>= 6.5)

**Runtime Dependencies:**
- `hyprland` (Wayland compositor)
- `glib`, `dconf`, `xrdb`, `lua5_4`
- `caelestia-cli` / `caelestia-shell` (optional for automatic scheme notifications)

#### Compilation Steps

```bash
# Clone the repository
git clone https://github.com/SpanishSyntax/Helm.git
cd Helm

# Configure with CMake and Ninja
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release

# Compile all C++ sources and compile GPU blob shaders
cmake --build build

# Install binaries, schemas, and desktop integration
sudo cmake --install build
```

This installs:
- Executables: `/usr/bin/flightdeck` and `/usr/bin/helm`
- Desktop Entry: `/usr/share/applications/flightdeck.desktop`
- Application Icon: `/usr/share/icons/hicolor/scalable/apps/flightdeck.svg`
- Schema Resources: `/usr/share/flightdeck/schema/*.json`

---

## Quick Start

### Summoning the Graphical Cockpit

You can launch the visual editor from your application runner (Rofi, Wofi, Walker, or Caelestia Launcher) or directly from the terminal:

```bash
helm
# or
flightdeck
```

The GUI will inspect your running Hyprland socket, read active display geometries, inspect loaded animations, and present the control cockpit.

---

### CLI Command Invocation

Helm provides a complete CLI interface designed for scripting and compositor keybindings.

```bash
# 1. Reload Hyprland compositor
helm reload

# 2. Query effective options
helm get terminal
helm get decoration:rounding
helm get animations:enabled --val-only

# 3. Live test and persist options
helm set terminal foot
helm set decoration:rounding 16
helm set general:gaps_in 8

# 4. Snapshot current configuration
helm profile create snapshot-before-tweak

# 5. Run health diagnostics
helm doctor
```

---

## Compositor Keybinding Setup

To summon Helm with a convenient keyboard shortcut, add a dispatch rule to your Hyprland configuration.

### In `~/.config/hypr/hyprland.conf`:
```ini
# Summon Helm Graphical Cockpit
bind = SUPER, H, exec, helm

# Quick Reload Compositor
bind = SUPER SHIFT, R, exec, helm reload
```

### In Caelestia Lua Config (`~/.config/caelestia/hypr-user.lua`):
```lua
-- Summon Helm Cockpit
bind("SUPER", "H", "exec, helm")

-- Quick reload compositor
bind("SUPER_SHIFT", "R", "exec, helm reload")
```

---

## Verifying Environment Health

Run `helm doctor` to confirm that all prerequisites, sockets, and configuration files are properly hooked:

```bash
helm doctor
```

Example diagnostic output:
```text
=== FlightDeck Compositor Doctor ===

[✓] Hyprland active: running (PID 1420)
[✓] Hyprland socket: /run/user/1000/hypr/a9807b1d.../.socket.sock (connected)
[✓] Hyprland event socket: connected
[✓] Caelestia dotfiles root: ~/.config/caelestia/
[✓] FlightDeck override file: ~/.config/caelestia/astra-flightdeck.lua (writable)
[✓] Hypr-user inclusion: ~/.config/caelestia/hypr-user.lua sources astra-flightdeck.lua
[✓] Theme scheme watcher: ~/.local/state/caelestia/scheme.json found
[✓] HyprPM status: hyprpm available (0 plugin errors detected)

Compositor health status: 100% OK. All systems operational.
```
