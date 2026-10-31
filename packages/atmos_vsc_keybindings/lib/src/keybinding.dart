/// One keyboard rule (`keybindings.json` item or `contributes.keybindings`).
///
/// ## ENG
/// Links a key chord to a [command] (optionally with [args] / [when]).
/// A leading `-` on [command] marks a removal rule.
///
/// ## RU
/// Связывает аккорд клавиш с [command] (опционально [args] / [when]).
/// Префикс `-` у [command] — правило снятия хоткея.
class VscKeybinding {
  /// Creates a keybinding rule.
  const VscKeybinding({
    required this.key,
    required this.command,
    this.when,
    this.args,
    this.mac,
    this.win,
    this.linux,
    this.systemWide,
  });

  /// Parses one keybinding object.
  factory VscKeybinding.fromJson(Map<String, Object?> json) {
    final key = json['key'];
    if (key is! String || key.trim().isEmpty) {
      throw const FormatException('key is required');
    }
    final command = json['command'];
    if (command is! String) {
      throw const FormatException('command must be a string');
    }
    return VscKeybinding(
      key: key,
      command: command,
      when: json['when'] as String?,
      args: json['args'],
      mac: json['mac'] as String?,
      win: json['win'] as String?,
      linux: json['linux'] as String?,
      systemWide: json['systemWide'] as bool?,
    );
  }

  /// Default key or key sequence (`ctrl+k ctrl+c`).
  final String key;

  /// Command id, `-commandId` removal, or empty string to disable.
  final String command;

  /// Context when-clause.
  final String? when;

  /// Arguments passed to the command.
  final Object? args;

  /// macOS-specific key override (contributions).
  final String? mac;

  /// Windows-specific key override (contributions).
  final String? win;

  /// Linux-specific key override (contributions).
  final String? linux;

  /// Register as a system-wide shortcut (user keybindings).
  final bool? systemWide;

  /// Whether this rule removes a binding (`-commandId`).
  bool get isRemoval => command.startsWith('-') && command.length > 1;

  /// Command id without a leading `-`.
  String get commandId => isRemoval ? command.substring(1) : command;

  /// Effective key for [platform] (`windows` / `macos` / `linux` / other → [key]).
  String keyForPlatform(String platform) {
    switch (platform) {
      case 'macos':
      case 'mac':
        return mac ?? key;
      case 'windows':
      case 'win':
        return win ?? key;
      case 'linux':
        return linux ?? key;
      default:
        return key;
    }
  }

  /// Chord parts of [keyForPlatform] (space-separated).
  List<String> chordParts({String platform = ''}) => keyForPlatform(platform)
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  /// JSON map suitable for `keybindings.json`.
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'command': command,
        if (when != null) 'when': when,
        if (args != null) 'args': args,
        if (mac != null) 'mac': mac,
        if (win != null) 'win': win,
        if (linux != null) 'linux': linux,
        if (systemWide != null) 'systemWide': systemWide,
      };

  @override
  bool operator ==(Object other) =>
      other is VscKeybinding &&
      other.key == key &&
      other.command == command &&
      other.when == when &&
      other.args == args &&
      other.mac == mac &&
      other.win == win &&
      other.linux == linux &&
      other.systemWide == systemWide;

  @override
  int get hashCode => Object.hash(
        key,
        command,
        when,
        args,
        mac,
        win,
        linux,
        systemWide,
      );
}
