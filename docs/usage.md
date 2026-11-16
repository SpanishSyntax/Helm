# Visual Studios & CLI Usage Guide

Helm provides a suite of dedicated visual studios for graphical configuration alongside a headless CLI for scripting and compositor automation.

---

## Visual Studios

### Display Layout Studio

The **Display Layout Studio** provides a 2D interactive canvas for arranging physical outputs, setting primary displays, and managing multi-monitor topologies.

```
┌────────────────────────────────────────────────────────┐
│ [● DP-1 (4K @ 144Hz)]      [● HDMI-A-1 (1440p @ 165Hz)]│
│  Scale: 1.5                 Scale: 1.0                 │
│  Position: (0, 0)           Position: (2560, 0)        │
│  [Primary]                  [Secondary]                │
└────────────────────────────────────────────────────────┘
```

#### Key Capabilities:
- **Magnetic Snapping**: Drag displays to align horizontal, vertical, or center baselines with sub-pixel precision.
- **Resolution & Refresh Rate**: Select from video modes reported directly by the Hyprland kernel DRM backend.
- **Fractional Scaling**: Adjust UI scaling (e.g. 1.0, 1.25, 1.5, 1.75, 2.0) with real-time viewport recalculation.
- **Display Rotation**: Rotate outputs (0°, 90°, 180°, 270°) for portrait monitors or code reading displays.
- **Variable Refresh Rate (VRR / Adaptive Sync)**: Enable or disable adaptive sync (FreeSync / G-Sync) per output.
- **Workspace Binding**: Assign default persistent workspaces (e.g. Workspaces 1–5 on DP-1, Workspaces 6–10 on HDMI-A-1).

---

### Bezier Curve & Velocity Studio

The **Bezier Curve Studio** provides visual editing for Hyprland window, workspace, and fade animations.

$$\mathbf{B}(t) = (1-t)^3 \mathbf{P}_0 + 3(1-t)^2 t \mathbf{P}_1 + 3(1-t) t^2 \mathbf{P}_2 + t^3 \mathbf{P}_3, \quad t \in [0, 1]$$

#### Interactive Controls:
- **Draggable Control Handles**: Interactively drag $P_1(x_1, y_1)$ and $P_2(x_2, y_2)$ to shape acceleration curves.
- **Real-Time Velocity Track**: Preview the instantaneous derivative (speed curve) to check for overshoot or harsh braking.
- **Animation Target Switcher**: Assign custom beziers to distinct targets:
  - `windows` (open, close, move)
  - `workspaces` (slide, slidevert, fade)
  - `layers` (layer-shell entry and exit)
  - `fade` (window opacity transitions)
  - `border` / `borderangle` (active border gradient rotations)
- **Presets**: Load Caelestia presets (`gentle`, `snappy`, `overshoot`, `bouncy`, `linear`) or save custom bezier definitions.

---

### Keybindings Suite & Conflict Detector

The **Keybindings Suite** audits and configures your compositor hotkeys:

- **Conflict Auditing**: Automatically scans registered bindings across all modifiers (`SUPER`, `CTRL`, `ALT`, `SHIFT`) and highlights conflicting keys.
- **Category Filter**: Filter keybindings by category:
  - *Window Management* (`killactive`, `togglefloating`, `fullscreen`, `pseudo`)
  - *Workspace Navigation* (`workspace`, `movetoworkspace`)
  - *Application Launchers* (`exec, kitty`, `exec, rofi`, `exec, walker`)
  - *Hardware Controls* (Volume, Brightness, Media playback)
- **Visual Keybind Recorder**: Press a keyboard shortcut to capture keycode and modifier combinations automatically.

---

### Window & Layer Rules Builder

Configure fine-grained compositor behaviors without memorizing regex syntax:

- **Live Client Inspector**: Click any open window to auto-populate its exact `class`, `title`, and `xwayland` properties.
- **Window Rules**:
  - `float`: Force window to float by default
  - `pin`: Pin floating window across all workspaces
  - `opacity`: Adjust active and inactive transparency
  - `workspace`: Bind application to spawn on a specific workspace
  - `size` & `center`: Specify initial window dimensions
- **Layer Rules**:
  - Configure `blur`, `ignorealpha`, and `dimaround` for Wayland layer-shell surfaces (e.g. notifications, status bars, launchers).

---

### Autostart & Startup Hooks

Manage applications and daemons executed upon Hyprland compositor initialization (`exec-once`):

- **Desktop Application Discovery**: Scans `/usr/share/applications/` and `~/.local/share/applications/` for installed apps.
- **System Daemons**: Toggle background agents (`swaybg`, `mako`, `dunst`, `waybar`, `quickshell`, `polkit-kde-agent`).
- **Custom Scripts**: Add custom terminal commands and background scripts with execution delay options.

---

### Cursor & Theme Watcher

- **Cursor Themes**: Discovers all installed Hyprcursor and XCursor themes in `/usr/share/icons` and `~/.icons`.
- **Instant Sizing**: Adjust cursor size (24, 32, 48, 64) with live `hyprctl setcursor` application without logging out.
- **Dynamic Scheme Synchronization**: Automatically listens for changes to `~/.local/state/caelestia/scheme.json` and updates UI styling in real time.

---

### HyprPM Plugin Management

Helm includes a visual and headless manager for `hyprpm` (Hyprland Plugin Manager):

- **Catalog Browser**: Browse popular community plugins (such as `hyprbars`, `hyprfocus`, `hyprexpo`, `hyprtrails`).
- **Install & Enable**: Clone, compile, and enable plugins with one click.
- **Repair Utility**: Resolves permission conflicts (e.g. root-owned headers in `~/.local/share/hyprpm`).

---

## CLI & Automation Reference

Helm can be driven headlessly from the command line using `helm` or `flightdeck`.

### CLI Command Overview

```text
Usage:
  helm <command> [arguments...] [options...]

Commands:
  reload                       Reload Hyprland compositor via IPC
  get <key> [--val-only]       Query effective configuration value
  set <key> <val> [--live]     Set and persist configuration value
  profile <subcommand>         Manage configuration profiles and snapshots
  doctor                       Run compositor and system diagnostics
  bind <subcommand>            Inspect and audit keybindings
  plugin <subcommand>          Manage Hyprland plugins via hyprpm
```

---

### Compositor Reload

Instantly reload Hyprland configuration via the UNIX domain socket:

```bash
helm reload
```

---

### Getting & Setting Variables

#### Querying Configuration Variables
Retrieve effective values combining Caelestia overrides, user configs, and Hyprland schema defaults:

```bash
# Query terminal command
helm get terminal

# Query window corner radius
helm get decoration:rounding

# Query raw value suitable for shell variables
ACTIVE_BORDER=$(helm get general:col.active_border --val-only)
```

#### Setting Configuration Variables
Update options cleanly:

```bash
# Set terminal emulator and persist to ~/.config/caelestia/astra-flightdeck.lua
helm set terminal kitty

# Set window gap spacing
helm set general:gaps_in 8
helm set general:gaps_out 16

# Set option only in running memory without writing to disk
helm set decoration:blur:enabled false --live
```

---

### Profile & Snapshot Automation

Create, list, restore, and delete configuration snapshots:

```bash
# List all saved profiles
helm profile list

# Create a snapshot before testing experimental setups
helm profile create snapshot-multimonitor

# Restore a saved profile
helm profile restore snapshot-multimonitor

# Delete an obsolete profile
helm profile delete old-profile
```

---

### Keybinding Inspector CLI

Audit and search keybindings from the terminal:

```bash
# List all active keybindings
helm bind list

# Check for modifier/key collisions
helm bind conflicts

# Find keybindings mapped to the Return key
helm bind find Return
```

---

### Compositor Doctor Diagnostics

Run an automated environment audit to detect broken sockets, missing dependencies, or permission issues:

```bash
helm doctor
```

Example diagnostics checked:
- Hyprland running status and process PID
- Hyprland command socket (`.socket.sock`) accessibility
- Hyprland event socket (`.socket2.sock`) accessibility
- Caelestia dotfiles root directory
- Override file (`astra-flightdeck.lua`) write permissions
- Inclusion hook in `hypr-user.lua`
- Caelestia dynamic scheme file (`scheme.json`)
- HyprPM status and directory permissions

---

### Plugin CLI Management

Manage Hyprland plugins without manual terminal commands:

```bash
# List installed plugins and catalog
helm plugin list

# Install a plugin repository
helm plugin install https://github.com/hyprwm/hyprland-plugins

# Enable an installed plugin
helm plugin enable hyprbars

# Disable a plugin
helm plugin disable hyprbars

# Update and recompile all installed plugins against current compositor
helm plugin update

# Fix root permission issues in ~/.local/share/hyprpm
helm plugin repair
```
