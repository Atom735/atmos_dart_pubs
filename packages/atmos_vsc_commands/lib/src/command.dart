import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';

/// Icon for a contributed command (`$(codicon)` or light/dark paths).
///
/// ## ENG
/// Mirrors VS Code `contributes.commands[].icon`.
///
/// ## RU
/// Соответствует `contributes.commands[].icon` в VS Code.
sealed class VscCommandIcon {
  const VscCommandIcon();

  /// Parses a string product icon or `{ light, dark }` paths.
  factory VscCommandIcon.fromJson(Object? json) {
    if (json is String) {
      return VscCommandProductIcon(json);
    }
    if (json is Map) {
      final map = json.cast<String, Object?>();
      final light = map['light'];
      final dark = map['dark'];
      if (light is String && dark is String) {
        return VscCommandThemeIcon(light: light, dark: dark);
      }
    }
    throw FormatException(
      'Expected icon string or {light, dark}, got ${json.runtimeType}',
    );
  }
}

/// Product / codicon reference, e.g. `$(book)`.
class VscCommandProductIcon extends VscCommandIcon {
  /// Creates a product icon.
  const VscCommandProductIcon(this.id);

  /// Icon id (`$(book)` or bare name).
  final String id;

  @override
  bool operator ==(Object other) =>
      other is VscCommandProductIcon && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Separate assets for light and dark UI.
class VscCommandThemeIcon extends VscCommandIcon {
  /// Creates a themed path pair.
  const VscCommandThemeIcon({required this.light, required this.dark});

  /// Path relative to the extension for light UI.
  final String light;

  /// Path relative to the extension for dark UI.
  final String dark;

  @override
  bool operator ==(Object other) =>
      other is VscCommandThemeIcon &&
      other.light == light &&
      other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);
}

/// A user-facing command contribution (`contributes.commands`).
///
/// ## ENG
/// Declares id + UI metadata. Handlers are registered at runtime separately.
///
/// ## RU
/// Id и UI-метаданные. Хендлеры регистрируются отдельно в runtime.
class VscCommand {
  /// Creates a command contribution.
  const VscCommand({
    required this.command,
    required this.title,
    this.shortTitle,
    this.category,
    this.enablement,
    this.icon,
  });

  /// Parses one command object from contribution JSON.
  factory VscCommand.fromJson(Map<String, Object?> json) {
    final command = json['command'];
    if (command is! String || command.trim().isEmpty) {
      throw const FormatException('command is required');
    }
    final title = json['title'];
    if (title == null) {
      throw const FormatException('title is required');
    }
    return VscCommand(
      command: command,
      title: VscLocalizedString.fromJson(title),
      shortTitle: json['shortTitle'] == null
          ? null
          : VscLocalizedString.fromJson(json['shortTitle']),
      category: json['category'] == null
          ? null
          : VscLocalizedString.fromJson(json['category']),
      enablement: json['enablement'] as String?,
      icon: json['icon'] == null ? null : VscCommandIcon.fromJson(json['icon']),
    );
  }

  /// Command identifier (`extension.sayHello`).
  final String command;

  /// Primary UI title.
  final VscLocalizedString title;

  /// Optional shorter title for compact menus.
  final VscLocalizedString? shortTitle;

  /// Optional category (Command Palette grouping).
  final VscLocalizedString? category;

  /// When-clause controlling enablement in menus / keybindings.
  final String? enablement;

  /// Optional icon.
  final VscCommandIcon? icon;

  /// Palette-style label: `Category: Title` when [category] is set.
  String get paletteLabel {
    final cat = category?.text;
    if (cat == null || cat.isEmpty) return title.text;
    return '$cat: ${title.text}';
  }

  @override
  bool operator ==(Object other) =>
      other is VscCommand &&
      other.command == command &&
      other.title == title &&
      other.shortTitle == shortTitle &&
      other.category == category &&
      other.enablement == enablement &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(
        command,
        title,
        shortTitle,
        category,
        enablement,
        icon,
      );
}
