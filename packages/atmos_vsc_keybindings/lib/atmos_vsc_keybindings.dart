/// Pure-Dart VS Code / Cursor keybinding dumps + hotkey engine.
///
/// ## ENG
/// Bundled OS defaults under `lib/assets/`. Resolve presses with
/// `VscKeybindingEngine`. Flutter helpers live in
/// `atmos_vsc_keybindings_flutter`.
///
/// ## RU
/// Бандл дефолтов в `lib/assets/`. Разрешение нажатий —
/// `VscKeybindingEngine`. Flutter — `atmos_vsc_keybindings_flutter`.
library atmos_vsc_keybindings;

export 'src/bundled.dart';
export 'src/engine.dart';
export 'src/key_parse.dart';
export 'src/key_stroke.dart';
export 'src/keybinding.dart';
export 'src/loader.dart';
export 'src/platform.dart';
export 'src/when.dart';
