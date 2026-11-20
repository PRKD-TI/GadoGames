---
name: godot-web-android-gamedev
description: >-
  Expert guidelines, workflows, and configurations for developing, building, and exporting
  cross-platform games in Godot 4 targeting both Web (HTML5/WebAssembly) and Android (Google Play Store).
  Use this skill whenever building, optimizing, or configuring Godot games for web browsers and mobile devices.
---

# Godot 4 Web & Android Cross-Platform Game Development

This skill provides step-by-step procedures, engine configurations, and best practices for creating games in Godot 4 that target both **Web Browsers (HTML5/Wasm)** and **Android Mobile (Google Play Store)** from a single unified codebase.

---

## 1. Core Engine Configurations

### 1.1 Rendering Method: Compatibility
* **Crucial Setting:** In `project.godot`, set rendering method to `gl_compatibility`.
  ```ini
  [rendering]
  renderer/rendering_method="gl_compatibility"
  renderer/rendering_method.mobile="gl_compatibility"
  renderer/rendering_method.web="gl_compatibility"
  ```
* **Why:** Mobile devices and browsers (WebGL 2.0) do not fully support Vulkan (`Forward+` or `Mobile`). Compatibility ensures 60 FPS, fast loading, and zero shader compile crashes on low/mid-range Androids and all modern browsers.

### 1.2 Viewport & Screen Responsiveness
* Multi-device display settings:
  ```ini
  [display]
  window/size/viewport_width=1280
  window/size/viewport_height=720
  window/stretch/mode="canvas_items"
  window/stretch/aspect="keep"
  window/handheld/orientation=1  # 1 = Sensor Landscape, 0 = Landscape, 4 = Sensor Portrait
  ```
* Set `window/stretch/mode="canvas_items"` so UI and 2D sprites scale crisply across different aspect ratios (16:9, 19.5:9, 21:9).

### 1.3 Touch Emulation for Development
* Enable mouse-to-touch emulation to test mobile controls seamlessly on PC:
  ```ini
  [input_devices]
  pointing/emulate_touch_from_mouse=true
  pointing/emulate_mouse_from_touch=true
  ```

---

## 2. Input Architecture (Dual Web & Mobile Controls)

Always implement dual-input handling in GDScript so the game works out-of-the-box with keyboard/gamepad AND touch buttons/gestures:

```gdscript
# Example: Input manager supporting Keyboard + On-screen Touch Controls
var input_direction: float = 0.0

func _process(delta: float) -> void:
    # Keyboard / Gamepad axis
    var keyboard_axis := Input.get_axis("ui_left", "ui_right")
    
    # Touch input (from custom on-screen UI buttons or joystick)
    var touch_axis := touch_ui_direction
    
    input_direction = clamp(keyboard_axis + touch_axis, -1.0, 1.0)
```

---

## 3. Web Export Requirements (HTML5)

Godot 4.3+ supports single-threaded web exports without needing cross-origin isolation headers (`COOP`/`COEP`):

1. **Export Presets (`export_presets.cfg`):**
   * Set `threads/thread_model=0` (Single-threaded) for maximum compatibility with itch.io, Netlify, GitHub Pages, and web hosting without custom server headers.
   * Audio: Enable Web Audio with auto-resume on first user click/touch.
2. **PWA (Progressive Web App):**
   * Can be enabled in export options for offline caching and "Install App" prompt on mobile browsers.

---

## 4. Android & Google Play Store Requirements

1. **Package Format:**
   * Google Play requires Android App Bundle (`.aab`) instead of `.apk`.
2. **Target SDK:**
   * Target SDK 34+ (Android 14) as mandated by Google Play policy.
3. **Permissions:**
   * Only request essential permissions (e.g. `VIBRATE` for haptic feedback). Do not request unused permissions to prevent Play Store review delays.
4. **Icons & Splash:**
   * Provide adaptive icons (Foreground + Background 432x432) and high-res launcher icons.

---

## 5. Directory & Asset Standards

* Keep texture sizes power-of-two or atlas compressed.
* Use `.ogg` for background music and `.wav` for low-latency sound effects.
* Group platform-specific UI under a CanvasLayer that can show/hide touch controls based on `OS.has_feature("mobile")` or `OS.has_feature("web_android")`.
