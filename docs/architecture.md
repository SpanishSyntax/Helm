# Architecture & Design

Helm (FlightDeck) is engineered with a hybrid architecture combining a high-performance **C++20 native core**, declarative **Qt 6 QML interfaces**, hardware-accelerated **SPIR-V fragment shaders**, and direct **Hyprland UNIX socket IPC**.

---

## System Architecture

The following diagram illustrates the data flow, IPC boundaries, and configuration synchronization across Helm and the host desktop environment:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        User & Compositor Plane                         │
│                    (Hyprland Wayland Compositor)                       │
└───────────────────┬────────────────────────────────▲───────────────────┘
                    │                                │
    Events Socket   │ (.socket2.sock)                │ IPC Commands (.socket.sock)
    (workspace,     │                                │ (dispatch, keyword,
     activewindow)  │                                │  hyprctl monitor...)
                    ▼                                │
┌────────────────────────────────────────────────────┴───────────────────┐
│                      Helm C++20 Core Backend                           │
│                                                                        │
│ ┌──────────────────────┐  ┌──────────────────────┐  ┌────────────────┐ │
│ │  HyprlandSocket      │  │  HyprlandEvents      │  │ HyprlandSchema │ │
│ │  • UNIX domain sock  │  │  • Async event loop  │  │ • JSON schemas │ │
│ │  • JSON deserializer │  │  • Threaded dispatch │  │ • Key mappings │ │
│ └──────────┬───────────┘  └──────────┬───────────┘  └───────┬────────┘ │
│            │                         │                      │          │
│ ┌──────────┴─────────────────────────┴──────────────────────┴────────┐ │
│ │                         Manager Layer                              │ │
│ │  • MonitorManager     • AnimationManager    • KeybindValidator     │ │
│ │  • AirlockManager     • AutostartManager    • ProfileManager       │ │
│ │  • HyprpmManager      • DiagnosticsManager  • CursorManager        │ │
│ └────────────────────────────────────┬───────────────────────────────┘ │
│                                      │                                 │
│ ┌────────────────────────────────────┴───────────────────────────────┐ │
│ │                    Caelestia Dotfiles Engine                       │ │
│ │  • FlightDeckWriter (Atomic Lua generator)                         │ │
│ │  • LuaValidator (Syntax verification & AST safety)                 │ │
│ │  • ThemeWatcher (Inotify watcher on scheme.json)                   │ │
│ └────────────────────────────────────┬───────────────────────────────┘ │
└──────────────────────────────────────┼─────────────────────────────────┘
                                       │ QML Context Properties & Signals
                                       ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        Qt 6 QML & Shader Plane                         │
│                                                                        │
│  ┌─────────────────────────┐         ┌───────────────────────────────┐ │
│  │    Visual Studios       │         │       GPU Blob Shaders        │ │
│  │ • DisplayLayout.qml     │         │ • blob.vert / blob.frag       │ │
│  │ • BezierEditor.qml      │         │ • QQuickRhiShaderCode (qsb)   │ │
│  │ • KeybindsManager.qml   │         │ • Signed distance fields      │ │
│  │ • RulesManager.qml      │         │ • Dynamic corner radius       │ │
│  └─────────────────────────┘         └───────────────────────────────┘ │
└──────────────────────────────────────┬─────────────────────────────────┘
                                       │ Non-Destructive Lua Overrides
                                       ▼
┌────────────────────────────────────────────────────────────────────────┐
│                 Filesystem Configuration Persistence                   │
│                                                                        │
│ ~/.config/caelestia/astra-flightdeck.lua ◄─── (Cleanly sourced by)     │
│ ~/.config/caelestia/hypr-user.lua        ───► (Passed to Hyprland)     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Why "Helm" & "FlightDeck"? (The Lore)

> **helm** (`/hɛlm/`) — *noun:* The tiller, wheel, and steering gear of an expedition vessel or icebreaker; the command post from which navigators steer safely through shifting pack ice and arctic waterways.

Navigating an expedition ship through arctic pack ice requires instant responsiveness and absolute structural integrity. A sudden rudder shift against a frozen ridge can stress the hull; an uncalibrated turn can run the vessel aground. The captain standing at the helm relies on a unified instrument deck—gyrocompass, engine telegraph, ballast telemetry, and radar—to command safe passage.

**Helm coordinates the modern Wayland cockpit:**
- **Steering the Fleet**: Just as an icebreaker's helm controls rudder angles and power output in harsh waters, Helm manages monitor layouts, bezier animation curves, window rules, and keybindings with instant Hyprland IPC feedback.
- **Non-Destructive Safe Passage**: Writes isolated overrides to `~/.config/caelestia/astra-flightdeck.lua` and sources it cleanly in `~/.config/caelestia/hypr-user.lua`, leaving base Hyprland configs untouched.

---

## C++20 & Qt 6 QML Engine

Helm is developed with modern C++20 and Qt 6.5+ using `Q_OBJECT` architectures, strong typing, and asynchronous IO:

### Decoupled Engine Architecture
- **Zero GUI Blocking**: All Hyprland socket transactions run on dedicated IO threads or non-blocking event loops, ensuring the 60/120/144/240Hz QML interface never drops frames during disk or compositor queries.
- **Fast Startup**: Pre-compiled QML bytecode and static JSON schema embeddings (`qrc:/schema/`) eliminate runtime filesystem discovery during startup, achieving instant application load times.
- **Memory Footprint**: Strict RAII and `QQmlEngine::CppOwnership` management keep baseline RAM usage lean (~28–42MB RSS).

---

## GPU Blob Shaders

Rather than relying on basic CSS-like boxes or slow blur passes, Helm renders its iconic organic surfaces and rounded card panels using custom GLSL shaders compiled via `qsb` (Qt Shader Baker):

### 1. Shader Pipeline
- **Vertex Shader** (`shaders/blob.vert`): Computes 4D screen-space transformations using uniform buffer blocks (`layout(std140, binding = 0)`).
- **Fragment Shader** (`shaders/blob.frag`): Evaluates exact mathematical 2D Signed Distance Fields (SDF) for arbitrary rounded rectangles, smooth metaball blending, and inverted corner masks.

### 2. High-Performance Anti-Aliasing
The shader employs hardware smoothstepping over local gradient derivatives:
$$\text{dist} = \text{sdfRoundedBox}(p - \text{center}, \text{halfSize}, \text{radius})$$
$$\alpha = \text{clamp}\left(0.5 - \frac{\text{dist}}{\text{fwidth}(\text{dist})}, 0.0, 1.0\right)$$

This delivers sub-pixel anti-aliasing across high-DPI screens without consuming CPU geometry cycles or creating extra vertex buffers.

---

## Hyprland IPC Protocol

Helm communicates with the Hyprland compositor over two dedicated UNIX domain sockets found in `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/`:

### 1. Synchronous Command Socket (`.socket.sock`)
Used for querying system state and issuing compositor commands:
- **`j/monitors`**: Returns JSON array of all active physical outputs, current modes, physical positions, scaling factors, refresh rates, and VRR states.
- **`j/workspaces`**: Returns active workspace mappings and monitor assignments.
- **`j/clients`**: Returns active window addresses, titles, classes, and floating geometry.
- **`j/layers`**: Returns active Wayland layer-shell surfaces and namespaces.
- **`j/binds`**: Returns all registered compositor keybindings and flags.
- **`j/animations`**: Returns all registered bezier curves, durations, and animation trees.
- **`dispatch <cmd> <args>`**: Executes live compositor actions (such as `dpms`, `workspace`, or `movewindow`).
- **`keyword <key> <val>`**: Dynamically injects variable overrides into the running compositor instance.

### 2. Asynchronous Event Socket (`.socket2.sock`)
A continuous broadcast stream from Hyprland informing Helm of external changes:
- `monitoradded>>...` / `monitorremoved>>...`: Triggers instant re-render of the Display Canvas.
- `workspace>>...` / `activewindow>>...`: Synchronizes active window inspection tools.
- `openwindow>>...` / `closewindow>>...`: Updates the Live Window Picker for window rules authoring.

---

## Non-Destructive Caelestia Engine

A common pitfall with compositor configurators is destructive file overwriting—corrupting user comments, destroying custom macros, or creating Git merge conflicts.

Helm eliminates this problem entirely through **Isolated Override Generation**:

### 1. The Override Pipeline
1. Upstream configuration files (`~/.config/hypr/hyprland.conf`, `variables.lua`, `hypr-user.lua`) remain untouched.
2. Helm writes all visual modifications into a dedicated override file:
   $$\texttt{\~/.config/caelestia/astra-flightdeck.lua}$$
3. Inside `~/.config/caelestia/hypr-user.lua`, a single clean inclusion line pulls in Helm's parameters:
   ```lua
   -- Source FlightDeck / Helm overrides
   pcall(dofile, os.getenv("HOME") .. "/.config/caelestia/astra-flightdeck.lua")
   ```

### 2. Lua Syntax & AST Validation
Before any buffer is flushed to disk:
- `LuaValidator` checks parenthesis matching, string quote escaping, and lexical structure.
- Atomic file writing guarantees that if power or the process terminates mid-write, the existing configuration remains pristine via temp-file renaming (`rename(tmp, target)`).

### 3. Reactive Theme Synchronization
Helm contains a real-time `ThemeWatcher` that tracks inotify events on `~/.local/state/caelestia/scheme.json`. When the user switches wallpaper, accent color, or light/dark mode via Caelestia CLI, Helm reloads its UI color tokens in real-time without restarting.
