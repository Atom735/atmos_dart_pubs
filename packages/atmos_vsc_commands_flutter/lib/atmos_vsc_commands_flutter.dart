/// Flutter adapters for `atmos_vsc_commands` — command host + shortcuts.
///
/// ## ENG
/// Canonical input: `VscCommandHost` (chords / when via keybindings engine).
/// `VscShortcuts` is a limited single-step helper. Key parsing lives in
/// `atmos_vsc_keybindings` / `atmos_vsc_keybindings_flutter`.
///
/// ## RU
/// Канон ввода: `VscCommandHost`. `VscShortcuts` — только single-step.
library atmos_vsc_commands_flutter;

export 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
export 'package:atmos_vsc_keybindings_flutter/atmos_vsc_keybindings_flutter.dart';

export 'src/command_host.dart';
export 'src/shortcuts.dart';
