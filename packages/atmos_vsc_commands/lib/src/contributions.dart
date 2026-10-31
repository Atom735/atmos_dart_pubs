import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';

import 'command.dart';

/// Parsed `contributes.commands` + `contributes.keybindings` block.
///
/// ## ENG
/// Usually extracted from an extension `package.json`.
///
/// ## RU
/// Обычно извлекается из `package.json` расширения.
class VscCommandContributions {
  /// Creates a contributions snapshot.
  const VscCommandContributions({
    this.commands = const [],
    this.keybindings = const [],
  });

  /// Parses a `contributes` map (or a root that contains `contributes`).
  factory VscCommandContributions.fromJson(Map<String, Object?> json) {
    final contributes = json['contributes'];
    final root = contributes is Map
        ? contributes.cast<String, Object?>()
        : json;

    return VscCommandContributions(
      commands: _parseCommands(root['commands']),
      keybindings: _parseKeybindings(root['keybindings']),
    );
  }

  /// Declared commands.
  final List<VscCommand> commands;

  /// Declared keybinding rules.
  final List<VscKeybinding> keybindings;

  /// Looks up a command by id.
  VscCommand? commandById(String id) {
    for (final command in commands) {
      if (command.command == id) return command;
    }
    return null;
  }

  static List<VscCommand> _parseCommands(Object? raw) {
    if (raw == null) return const [];
    final items = raw is List ? raw : <Object?>[raw];
    final out = <VscCommand>[];
    for (final item in items) {
      if (item is Map) {
        out.add(VscCommand.fromJson(item.cast<String, Object?>()));
      }
    }
    return List<VscCommand>.unmodifiable(out);
  }

  static List<VscKeybinding> _parseKeybindings(Object? raw) {
    if (raw == null) return const [];
    final list = raw is List ? raw : <Object?>[raw];
    return VscKeybindingsLoader.parseDecoded(list);
  }
}
