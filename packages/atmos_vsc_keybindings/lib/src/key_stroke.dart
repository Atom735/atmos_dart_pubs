/// One chord step: modifiers + trigger key token (`ctrl+k`).
///
/// ## ENG
/// Platform-agnostic; trigger is a VS Code key token (`a`, `escape`, `f5`).
///
/// ## RU
/// Без Flutter; trigger — токен VS Code (`a`, `escape`, `f5`).
class VscKeyStroke {
  /// Creates a stroke.
  const VscKeyStroke({
    required this.key,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  /// Trigger key token (lowercase VS Code name).
  final String key;

  /// Ctrl / Control.
  final bool control;

  /// Shift.
  final bool shift;

  /// Alt / Option.
  final bool alt;

  /// Meta / Win / Cmd.
  final bool meta;

  /// Canonical string (`ctrl+shift+k`).
  String toKeyString() {
    final parts = <String>[];
    if (control) parts.add('ctrl');
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    if (meta) parts.add('meta');
    parts.add(key);
    return parts.join('+');
  }

  @override
  bool operator ==(Object other) =>
      other is VscKeyStroke &&
      other.key == key &&
      other.control == control &&
      other.shift == shift &&
      other.alt == alt &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(key, control, shift, alt, meta);

  @override
  String toString() => 'VscKeyStroke(${toKeyString()})';
}

/// Incoming key event for the hotkey engine (same shape as [VscKeyStroke]).
typedef VscKeyEvent = VscKeyStroke;
