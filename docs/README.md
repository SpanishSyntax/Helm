<p align="center">
  <img src="assets/banner.jpg" alt="Helm Banner" width="100%" />
</p>

# Helm ⚓

A modern, visual Hyprland configuration manager, monitor coordinator, and animation studio for the AstraSuite and Frost ecosystems, built with Qt 6, C++20, and QML.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/SpanishSyntax/Helm/blob/main/LICENSE)
[![C++20](https://img.shields.io/badge/C++-20-00599C.svg?logo=c%2B%2B&logoColor=white)](https://github.com/SpanishSyntax/Helm/blob/main/CMakeLists.txt)
[![Qt 6.5+](https://img.shields.io/badge/Qt-6.5+-41CD52.svg?logo=qt&logoColor=white)](https://github.com/SpanishSyntax/Helm/blob/main/CMakeLists.txt)
[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3.svg?logo=nixos&logoColor=white)](https://github.com/SpanishSyntax/Helm/blob/main/flake.nix)

Helm (also invoked as `flightdeck`) provides a high-performance visual cockpit and automated management suite for Hyprland compositors. It blends hardware-accelerated Qt 6 QML graphics with deep Hyprland IPC socket integration, allowing users to configure multi-monitor physical topology, author cubic-bezier velocity curves, audit keybindings, configure window rules, and switch profiles without manual file editing.

---

## Why "Helm" & "FlightDeck"? (The Lore)

> **helm** (`/hɛlm/`) — *noun:* The tiller, wheel, and steering gear of an expedition vessel or icebreaker; the command post from which navigators steer safely through shifting pack ice and arctic waterways.

When navigating high-latitude ice pack, an icebreaker cannot afford erratic steering or mechanical stress. The navigator standing at the helm commands the vessel's rudders, directs bow thrusters, monitors sonar depth soundings, and coordinates ballast distribution to carve safe shipping lanes through pack ice.

**Helm steers your Wayland compositor:**
- **Steering the Fleet**: Just as an icebreaker's helm controls rudder angles and power output in harsh waters, Helm manages monitor layouts, bezier animation curves, window rules, and keybindings with instant Hyprland IPC feedback.
- **Non-Destructive Safe Passage**: Writes isolated overrides to `~/.config/caelestia/astra-flightdeck.lua` and sources it cleanly in `~/.config/caelestia/hypr-user.lua`, leaving base Hyprland configs untouched.

---

## Architecture Highlights

- **C++20 & Native Qt 6 Engine**: Ultra-fast native backend using Qt Quick, C++20 controllers, and asynchronous thread pooling for compositor queries.
- **Hardware-Accelerated Blob Shaders**: Custom GPU vertex and fragment shaders (`blob.vert` and `blob.frag`) compiled to SPIR-V via `qsb` (Qt Shader Baker), producing organic, fluid Material 3 background surfaces.
- **Bi-Directional Hyprland IPC**: Asynchronous UNIX domain socket communication (`$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock` and `.socket2.sock`) for immediate parameter injection without restarting the compositor.
- **Isolated Non-Destructive Storage**: Edits reside in an isolated override layer (`astra-flightdeck.lua`), never clobbering upstream dotfiles or Git tracking.
- **Dynamic Caelestia Scheme Synchronization**: Inotify watcher detects changes to `~/.local/state/caelestia/scheme.json`, automatically repainting QML palettes without restarting the application.
- **Full CLI Suite & Automated Diagnostics**: Complete command-line driver (`helm get`, `set`, `reload`, `profile`, `bind`, `plugin`) and an automated compositor diagnostic engine (`helm doctor`).

---

## Quick Start

```bash
# Launch the visual cockpit GUI
helm
# or
flightdeck

# Instantly reload Hyprland compositor
helm reload

# Query effective configuration value
helm get terminal

# Set configuration variable and persist cleanly
helm set windowRounding 12

# Run health diagnostics on Hyprland sockets and files
helm doctor
```

---

## Documentation Roadmap

- [Getting Started](getting-started.md)
  - [Installation Guide](getting-started.md#installation)
  - [Nix Flake & Home Manager](getting-started.md#nix-flake--home-manager)
  - [Arch Linux / AUR](getting-started.md#arch-linux--aur)
  - [Building from Source](getting-started.md#building-from-source)
  - [Quick Start](getting-started.md#quick-start)
- [Architecture & Design](architecture.md)
  - [System Architecture](architecture.md#system-architecture)
  - [The Lore: Icebreakers & Helm](architecture.md#why-helm--flightdeck-the-lore)
  - [C++20 & Qt 6 QML Engine](architecture.md#c20--qt-6-qml-engine)
  - [GPU Blob Shaders](architecture.md#gpu-blob-shaders)
  - [Hyprland IPC Protocol](architecture.md#hyprland-ipc-protocol)
  - [Non-Destructive Caelestia Engine](architecture.md#non-destructive-caelestia-engine)
- [Visual Studios & Features](usage.md)
  - [Display Layout Studio](usage.md#display-layout-studio)
  - [Bezier Curve & Velocity Studio](usage.md#bezier-curve--velocity-studio)
  - [Keybindings Suite & Conflict Detector](usage.md#keybindings-suite--conflict-detector)
  - [Window & Layer Rules Builder](usage.md#window--layer-rules-builder)
  - [Autostart & Startup Hooks](usage.md#autostart--startup-hooks)
  - [Cursor & Theme Watcher](usage.md#cursor--theme-watcher)
  - [HyprPM Plugin Management](usage.md#hyprpm-plugin-management)
- [CLI & Automation Reference](usage.md#cli-command-overview)
  - [Command Overview](usage.md#cli-command-overview)
  - [Compositor Reload](usage.md#compositor-reload)
  - [Getting & Setting Variables](usage.md#getting--setting-variables)
  - [Profile & Snapshot Automation](usage.md#profile--snapshot-automation)
  - [Keybinding Inspector CLI](usage.md#keybinding-inspector-cli)
  - [Compositor Doctor Diagnostics](usage.md#compositor-doctor-diagnostics)
  - [Plugin CLI Management](usage.md#plugin-cli-management)
