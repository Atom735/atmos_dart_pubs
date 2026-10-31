import 'package:atmos_vsc_keybindings_flutter/atmos_vsc_keybindings_flutter.dart';
import 'package:flutter/widgets.dart';

/// Intent carrying a VS Code command id (and optional args).
///
/// ## ENG
/// Use with `Shortcuts` / `Actions` for **single-step** bindings.
/// Prefer `VscCommandHost` for full chord + when support.
///
/// ## RU
/// Для `Shortcuts` / `Actions` (только single-step). Для аккордов —
/// `VscCommandHost`.
class VscCommandIntent extends Intent {
  /// Creates an intent for [commandId].
  const VscCommandIntent(this.commandId, {this.args});

  /// Command identifier (without `-` removal prefix).
  final String commandId;

  /// Optional arguments from the keybinding.
  final Object? args;
}

/// Flutter helpers for [VscKeybinding] lists.
extension VscKeybindingFlutter on VscKeybinding {
  /// Platform-aware key string for parsing.
  String effectiveKey({String? platform}) {
    final explicit = platform;
    if (explicit != null && explicit.isNotEmpty) {
      return keyForPlatform(explicit);
    }
    return keyForPlatform(VscFlutterKeyBridge.currentPlatform.id);
  }

  /// Single-step [SingleActivator], or `null` for chords / empty / removal.
  SingleActivator? toSingleActivator({String? platform}) {
    if (isRemoval || command.isEmpty) return null;
    final key = effectiveKey(platform: platform);
    try {
      final strokes = VscKeyStrokeParser.parse(key);
      if (strokes.length != 1) return null;
      return VscFlutterKeyBridge.toSingleActivator(strokes.first);
    } on FormatException {
      return null;
    }
  }
}

/// Result of converting keybindings to a Flutter `Shortcuts` map.
class VscShortcutsMap {
  /// Creates a conversion result.
  const VscShortcutsMap({
    required this.shortcuts,
    required this.skippedChords,
    required this.skippedRemovals,
  });

  /// Activator → [VscCommandIntent] for single-key rules.
  final Map<ShortcutActivator, Intent> shortcuts;

  /// Multi-chord bindings that were not mapped.
  final List<VscKeybinding> skippedChords;

  /// Removal / empty-command rules that were not mapped.
  final List<VscKeybinding> skippedRemovals;
}

/// Builds Flutter `Shortcuts` tables from VS Code keybinding rules.
///
/// ## ENG
/// **Incomplete vs VS Code:** skips chords and ignores `when`. Prefer
/// `VscCommandHost` + `VscKeybindingEngine` for real input.
///
/// ## RU
/// Без аккордов и `when`. Для полного ввода — `VscCommandHost`.
abstract final class VscShortcuts {
  /// Converts [bindings] into a [VscShortcutsMap].
  ///
  /// Later rules overwrite earlier ones for the same activator.
  static VscShortcutsMap build(
    Iterable<VscKeybinding> bindings, {
    String? platform,
  }) {
    final shortcuts = <ShortcutActivator, Intent>{};
    final skippedChords = <VscKeybinding>[];
    final skippedRemovals = <VscKeybinding>[];
    final platformId = platform ?? VscFlutterKeyBridge.currentPlatform.id;

    for (final binding in bindings) {
      if (binding.isRemoval || binding.command.isEmpty) {
        skippedRemovals.add(binding);
        continue;
      }
      final key = binding.keyForPlatform(platformId);
      List<VscKeyStroke> strokes;
      try {
        strokes = VscKeyStrokeParser.parse(key);
      } on FormatException {
        continue;
      }
      if (strokes.length > 1) {
        skippedChords.add(binding);
        continue;
      }
      final activator = VscFlutterKeyBridge.toSingleActivator(strokes.first);
      if (activator == null) continue;
      shortcuts[activator] = VscCommandIntent(
        binding.commandId,
        args: binding.args,
      );
    }

    return VscShortcutsMap(
      shortcuts: Map<ShortcutActivator, Intent>.unmodifiable(shortcuts),
      skippedChords: List<VscKeybinding>.unmodifiable(skippedChords),
      skippedRemovals: List<VscKeybinding>.unmodifiable(skippedRemovals),
    );
  }
}
