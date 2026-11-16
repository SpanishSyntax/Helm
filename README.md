<p align="center">
  <img src="assets/banner.jpg" alt="Helm Banner" width="100%" />
</p>

# Helm ⚓

A modern, visual Hyprland configuration manager, monitor coordinator, and animation studio for the AstraSuite and Frost ecosystems, built with Qt 6, C++20, and QML.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![C++20](https://img.shields.io/badge/C++-20-00599C.svg?logo=c%2B%2B&logoColor=white)](CMakeLists.txt)
[![Qt 6.5+](https://img.shields.io/badge/Qt-6.5+-41CD52.svg?logo=qt&logoColor=white)](CMakeLists.txt)
[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3.svg?logo=nixos&logoColor=white)](flake.nix)

Helm (also invoked as `flightdeck`) provides a high-performance visual cockpit and automated management suite for Hyprland compositors. It blends hardware-accelerated Qt 6 QML graphics with deep Hyprland IPC socket integration, allowing users to configure multi-monitor physical topology, author cubic-bezier velocity curves, audit keybindings, configure window rules, and switch profiles without manual file editing.

> [!TIP]
> **Documentation Site:** Complete architecture deep-dives, component schemas, and CLI references are available at the **[Helm Documentation Site](https://spanishsyntax.github.io/Helm)**.

---

## Why "Helm" & "FlightDeck"? (The Lore)

> **helm** (`/hɛlm/`) — *noun:* The tiller, wheel, and steering gear of an expedition vessel or icebreaker; the command post from which navigators steer safely through shifting pack ice and arctic waterways.

When traversing glacial straits, an icebreaker cannot afford erratic heading changes or hull strain. The navigator at the helm commands engine power, coordinates ballast distribution, and tracks radar vectors to pilot the fleet without collisions.

**Helm steers your Wayland compositor:**
- **Steering the Fleet**: Just as an icebreaker's helm controls rudder angles and power output in harsh waters, Helm manages monitor layouts, bezier animation curves, window rules, and keybindings with instant Hyprland IPC feedback.
- **Non-Destructive Safe Passage**: Writes isolated overrides to `~/.config/caelestia/astra-flightdeck.lua` and sources it cleanly in `~/.config/caelestia/hypr-user.lua`, leaving base Hyprland configs untouched.

---

## Features

- **Display & Monitor Layout Preview**: Interactive 2D canvas with magnetic edge snapping, resolution and refresh rate pickers, fractional scaling, rotation, and VRR with live Hyprland IPC sync.
- **Bezier Curve & Animation Studio**: Graphical cubic-bezier curve editor with draggable control handles, real-time velocity track preview, and Caelestia animation presets (`~/.config/caelestia/animations/*.lua`).
- **Keybindings Suite & Conflict Detector**: Live keybind auditing, multi-modifier search, category filtering, and real-time conflict identification.
- **Window & Layer Rules Management**: Visual rule builder for window state (floating, pinned, opacity, workspace placement) and layer blur with live window client and layer namespace pickers.
- **Autostart Manager**: Discovery and toggling of desktop applications, system daemons, and custom startup hooks.
- **Cursor Themes & Scaling**: System-wide Hyprcursor and XCursor theme discovery and instant sizing via `hyprctl setcursor`.
- **HyprPM Plugin Management**: Full lifecycle management for Hyprland plugins (search catalog, install, enable, disable, compile update, and repair permission issues).
- **Profiles & Backup Snapshots**: Instant snapshot creation, profile restoration, and sparse change review before saving.
- **Hardware-Accelerated UI**: Qt Quick with custom GPU blob vertex/fragment shaders (`shaders/blob.vert`, `shaders/blob.frag` compiled via `qsb`), Google Sans Flex variable typography, and live Caelestia color scheme reloading.
- **Full CLI Suite & Doctor**: Complete headless control (`helm get`, `set`, `reload`, `profile`, `bind`, `plugin`) and an automated `doctor` diagnostic suite for compositor health checks.

---

## Installation

### Nix Flake & Home Manager (Recommended)

Helm is distributed as a Nix Flake with native NixOS and Home Manager integration.

#### Run Directly via Nix
```bash
nix run github:SpanishSyntax/Helm
```

#### Flake Input
Add Helm to your `flake.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    helm = {
      url = "github:SpanishSyntax/Helm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, helm, ... }: {
    # NixOS or Home Manager configuration
  };
}
```

#### Home Manager Module
Enable the module in your Home Manager configuration:
```nix
{ inputs, pkgs, ... }: {
  imports = [
    inputs.helm.homeManagerModules.default
  ];

  programs.helm = {
    enable = true;
    # package = inputs.helm.packages.${pkgs.system}.default; # optional override
  };
}
```
*(Note: `programs.flightdeck.enable = true;` is also supported as an alias).*

---

### Arch Linux / AUR

Helm is available under its binary name `astra-flightdeck`:

```bash
# Release (builds from source)
paru -S astra-flightdeck

# Latest git trunk
paru -S astra-flightdeck-git
```

---

### Manual Installation (From Source)

#### Build Dependencies
- C++20 compiler (GCC 11+ or Clang 13+)
- CMake (>= 3.19)
- Ninja
- pkg-config
- Qt 6.5+ (Core, Gui, Widgets, Quick, QuickControls2, ShaderTools, Concurrent, Network, DBus, Svg)

#### Runtime Dependencies
- `hyprland` (running compositor)
- `glib`, `dconf`, `xrdb`, `lua5_4`
- `caelestia-cli` / `caelestia-shell` (optional for live token synchronization)

```bash
git clone https://github.com/SpanishSyntax/Helm.git
cd Helm

# Configure and compile using CMake and Ninja
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build

# Install binaries, desktop launcher, and schema files
sudo cmake --install build
```

This installs:
- Binary: `/usr/bin/flightdeck` (and symlinked `/usr/bin/helm`)
- Desktop Launcher: `/usr/share/applications/flightdeck.desktop`
- App Icon: `/usr/share/icons/hicolor/scalable/apps/flightdeck.svg`
- Hyprland Schemas: `/usr/share/flightdeck/schema/`

---

## Usage

### Graphical Cockpit

Launch the visual interface from your application launcher or terminal:

```bash
helm
# or
flightdeck
```

---

### CLI Command Suite

Helm exposes a rich command-line interface for scripts, terminal keybindings, and automation:

#### 1. Compositor Reload
Trigger an instant Hyprland configuration reload via IPC:
```bash
helm reload
```

#### 2. Query Configuration Variables
Read effective values (merging Caelestia overrides, user configs, and Hyprland schema defaults):
```bash
helm get terminal
helm get windowRounding
helm get blurEnabled --val-only
```

#### 3. Update Configuration Variables
Set variables with optional live compositor injection:
```bash
# Set and persist to ~/.config/caelestia/astra-flightdeck.lua
helm set terminal kitty
helm set windowRounding 12
helm set blurEnabled true

# Set only live in the running Hyprland instance without saving
helm set animationSpeed 1.5 --live
```

#### 4. Keybinding Inspection & Conflict Auditing
Audit active keybinds and find collision hotkeys:
```bash
# List all active keybindings
helm bind list

# Check for modifier/key collisions
helm bind conflicts

# Find keybind mapped to a specific key
helm bind find Return
```

#### 5. Profile Management
Snapshot and switch between desktop configurations:
```bash
helm profile list
helm profile create gaming-rig
helm profile restore default
helm profile delete old-setup
```

#### 6. Compositor Doctor Diagnostics
Audit compositor socket health, configuration files, and plugin permissions:
```bash
helm doctor
```

#### 7. HyprPM Plugin Automation
Manage Hyprland plugins headlessly:
```bash
helm plugin list
helm plugin install https://github.com/hyprwm/hyprland-plugins
helm plugin enable hyprbars
helm plugin update
helm plugin repair
```

---

## Architectural Principles

1. **Non-Destructive Guarantee**: Helm never overwrites upstream `hyprland.conf` or user customizations. All generated settings are placed into `~/.config/caelestia/astra-flightdeck.lua` and linked into `~/.config/caelestia/hypr-user.lua`.
2. **Sub-millisecond IPC**: Commands communicate directly over `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock` with zero intermediate daemons.
3. **GPU-Accelerated Visual Shaders**: Dynamic blob backgrounds are rendered using hardware vertex and fragment SPIR-V pipelines via `Qt6::ShaderTools`.
4. **Theme Reactivity**: Automatically watches `~/.local/state/caelestia/scheme.json` via inotify, updating palette tokens and window colors in real time.

---

## Acknowledgements

- UI design language, tokens, and components adapted from [Caelestia Shell](https://github.com/caelestia-dots/shell).
- Hyprland compositor by Vaxry and the Hyprland team.
- Material Design icons and specifications by Google.
- Reference concepts from [Hyprmod](https://github.com/bluemancz/hyprmod).

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for details.
