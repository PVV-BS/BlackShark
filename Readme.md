# Black Shark Graphics Engine

Black Shark Graphics Engine is a simple 2D and 3D engine written in Pascal, designed to enable developers to create applications using hardware-accelerated graphics. It supports Lazarus (v. >= 2.0) and Delphi.

This is a young, freely available project currently focused on 2D development. However, you can also create 3D objects (see test examples `TBSTestMesh`, `TBSTestEarth` in the unit `bs.test.mesh.pas`). The main goal of the project is to provide the simplest entities for easy access to OpenGL API features (version >= ES2).

- [Official Website](https://bshark.org/)
- [Repository](https://github.com/PVV-BS/BlackShark)
- [Telegram Channel](https://t.me/BSharkGE)
- [YouTube Channel](https://www.youtube.com/@blackshark28)

---

### 07.06.22 — Version 4.0
- Added support for Android OS.  
  See test project: `./tests/lazarus/Android/HelloBlackShark/jni/blackshark.lpr`  
  And its application wrapper for Android Studio: `./tests/lazarus/Android/HelloBlackShark`.  
  You must create an `assets` directory and copy all folders from `bin`, excluding platform-specific folders (e.g., `Win32`, `Win64`).  
  To compile for ARM architecture, change `x86_64` to `armeabi` in the `build.gradle` file and select the **Arm** build profile in Lazarus (Options → Compiler Options → Build Modes).

- Added support for Ultibo OS.  
  See test project: `./tests/lazarus/Ultibo/BSApplication/BSApplication.lpr`.  
  Use this IDE for compilation: [Ultibo Core Installer](https://github.com/ultibohub/Core/releases/download/2.5.037/Ultibo-Core-2.5.037-Beetroot.exe).

- Successfully runs on Raspberry Pi OS without special implementation.
- Improved high DPI support for default GUI sizes.
- Enhanced adaptive FPS for pure Black Shark applications.
- Fixed issues in `TBTable`.
- Refactored GL context creation, `bs.font`, `bs.renderer` (fixed multiple render passes), `bs.config` (added save/load functionality), and `bs.gui.chat`.

---

### 06.02.22 — Version 3.02
- Improved `TPath`:
    - Added support for multi-color paths.
    - Stroke drawing is now enabled when `StrokeLength > 0`.
    - `TPathMultiColored` has been marked as deprecated due to these changes.
- Enabled `BSConfig.MaxFPS` in the following projects:
    - `tests/delphi/VCL/AppTestVCL`
    - `tests/lazarus/LazTests`
- Default behavior for `TBlackSharkViewport`: if `BSConfig.MaxFPS` is disabled, redrawing occurs only when events are received from the OS.

---

### 17.01.22 — Version 3.0
- Removed all dependencies on LCL/VCL/FMX from all units, except `bs.viewport`.
- Introduced a new pure Black Shark application (see examples `/tests/delphi/BSApplication` and `/tests/lazarus/BSApplication`). Also supports Delphi Linux target compilation.
- Implemented a new native windowing system (see example `bs.test.windows.TBSTestWindows` via command-line parameters in `BSApplication`).
- Improved performance for applications based on `TBlackSharkViewPort` (LCL/VCL).
- Added a new built-in PNG image decoder.
- Automatically supports 32-bit indices for meshes: if the number of indices exceeds 65,536, the index buffer switches from 16-bit to 32-bit format.
- Fixed range errors in `bs.font` (previously occurred under "Range Check Error" compilation mode).
- Added new property: `bs.renderer.TBlackSharkRenderer.FPS`.
- Improved performance for `TPath` and its descendants: paths with thickness 1 pixel are now drawn using `GL_LINE_STRIP`.
- Fixed alignment issues in `bs.align` (right/bottom anchor positioning).
- Updated Telegram channel link: [https://t.me/BSharkGE](https://t.me/BSharkGE)

---

### 05.10.2021 — Version 2.02
- Added COLLADA 3D scene and object loader (see example `TBSTestCollada`).
- Implemented skeletal animation.
- Added instancing for 2D primitives via `TBlackSharkInstancing2d` (see example `TBSTestInstancing2d`).
- Each instance in `bs.instancing.TBlackSharkInstancing` now has its own color.
- In `bs.canvas.TArc`:
    - Added new property `Position2dCenter`.
    - Added `InterpolateFactor` to control smoothing degree.
- In `bs.canvas.TPath`:
    - Added arc-based drawing (see example `TBSTestCanvasPathArc`).
    - Added `InterpolateFactor` for curve smoothing.
- Introduced `TPathMultiColored`: a path where each point can have its own color.
- In `TBSTest`:
    - Added camera movement and key event handling.
    - Implemented virtual methods for mouse input.
    - Added new mouse-driven camera actions: rotate and move.
    - Added `Allow3dManipulationByMouse` property.
- Separated platform-dependent binary resources into directories.
- Improved shader usage: uniforms are now selected when assigned to an object, avoiding explicit shader type casting.
- Added virtual method `DefaultName` in `bs.shader.TBlackSharkShader`, eliminating the need to remember shader file names.
- Fixed several bugs in `TheXmlWriter`.

---

### 15.05.2021 — Minor Version 2.01
- Added delayed scroll for `TBSpinEdit` and `TBScrollBar` (scroll starts after holding the button for one second).
- Fixed EGL initialization (incorrect `EGLint` definition in header).
- Removed WGL support.
- Removed generic method from `TBCustomTable` due to FPC 3.2.0 compilation issues (only supported in FPC 3.2.1).
- Fixed incorrect cursor movement in `TBCustomTable` when navigating with keyboard (up/down).
- Removed problematic line from `TBCheckBox`.
- Adjusted boundaries in `TBlackSharkKDTree` to `(-MaxSingle, MaxSingle)` to prevent FPC from failing to copy `Double` to `Single`.
- Added new multisampling option: `BSConfig.MultiSamplingSamples`.
- Enhanced KD-tree test: added object motion, optional node visualization every second, and a help panel.
- Restored `TBSTestScrollBox` to working state.
- Temporarily excluded `TBSTestMemo` and `TBSTestTrueTypeSmiles` (not ready, especially `TBSTestTrueTypeSmiles` on Linux).

---

### 02.05.2021 — Version 2.0
- Changed license from custom to free LGPL.
- Added hardware multisampling support.
- Added FMX viewport support (limited testing so far).
- Canvas (`TBCanvas`) and related objects:
    - Implemented a unified scaling mechanism.
    - Added alignment options: anchors, margins, paddings, and alignment patterns (`TObjectAlign`).
    - `TFreeShape`: free-form shape builder with closed contours (see gallery).
    - `TFog`: simple rectangle background with custom shader.
    - `TCanvasLayout`: invisible container that does not consume GPU resources.
    - `TPath`: added drag-and-drop for control points.
    - `TrapezeRound`
    - `TMultiColoredShape`
    - `TColorSelector`
    - `TBiColoredSolidLines`
    - Removed `TBlackSharkPen`.

- New UI controls:
    - `TBEdit`
    - `TBSpinEdit`
    - `TObjectInspector`
    - `TBForm`
    - `TBColorDialog`
    - `TBCustomColorBox`
    - `TBTrackBar`
    - `TBGroupBox`
    - `TBCheckBox`
    - `TBTable`
    - `TBComboBox`

- Slightly improved font rasterization quality.
- Migrated RTTI format from binary to XML for easier VCS diff comparison.
- Implemented KD-Tree via `TBlackSharkKDTree`.
- Refactored `TBScene`:
    - Moved rendering logic to `bs.renderer`.
    - Integrated KD-Tree for spatial organization.
- Refactored UI controls: `TBScrolledWindow`, `TBScrollBar`, `TBButton`.
- Added `THashTable<K, V>` to `bs.collection`.
- Context initialization:
    - Switched to shared context.
    - Implemented smart initialization (no `eglChooseConfig`; attributes selected from desired to supported).
- Centralized management of fonts, textures, and shaders—now globally managed across contexts.
- Added new autotest project: `AutoTests.dpr`.
- Added new methods in `TBlackSharkViewPort` for autotesting (prefixed with "Test").
- Updated `libEGL` and `libGLESv2` libraries for Windows.
- Moved hardware multisampling option to `BSConfig.Multisampling`.
- Now runs animations and events on a single global thread (`GuiThread`) by default (see `bs.thread.CreateThreads`). Can be modified at any time.
- Fixed numerous bugs in the `bs.scheme` namespace.

---

### 28.05.2019 — Minor Version 1.02

Minor updates and fixes.

---

### 18.05.2019 — First Release!

Initial public release of the Black Shark Graphics Engine.