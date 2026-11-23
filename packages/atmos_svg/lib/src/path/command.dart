/// One SVG path command letter with numeric arguments.
///
/// Одна команда SVG path: буква и числовые аргументы.
class SvgPathCommand {
  /// Creates a command. [letter] is a single SVG path letter (`M`, `c`, …).
  ///
  /// Создаёт команду. [letter] — одна буква SVG path (`M`, `c`, …).
  SvgPathCommand(this.letter, List<double> args)
      : assert(letter.length == 1, 'Path letter must be one character'),
        args = List<double>.unmodifiable(args);

  /// Command letter (`M`, `m`, `L`, `C`, `Z`, …).
  ///
  /// Буква команды (`M`, `m`, `L`, `C`, `Z`, …).
  final String letter;

  /// Numeric arguments in command order.
  ///
  /// Числовые аргументы в порядке команды.
  final List<double> args;

  /// Whether [letter] is absolute (uppercase).
  ///
  /// Абсолютная ли команда (заглавная буква).
  bool get isAbsolute => letter == letter.toUpperCase();

  /// Uppercase form of [letter].
  ///
  /// Заглавная форма [letter].
  String get type => letter.toUpperCase();

  /// Copy with optional new [letter] / [args].
  ///
  /// Копия с опциональными новыми [letter] / [args].
  SvgPathCommand copyWith({String? letter, List<double>? args}) =>
      SvgPathCommand(letter ?? this.letter, args ?? this.args);

  @override
  String toString() {
    if (args.isEmpty) return letter;
    final buf = StringBuffer(letter);
    for (var i = 0; i < args.length; i++) {
      if (i > 0) buf.write(' ');
      buf.write(_fmt(args[i]));
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is SvgPathCommand &&
      other.letter == letter &&
      _listEq(other.args, args);

  @override
  int get hashCode => Object.hash(letter, Object.hashAll(args));
}

bool _listEq(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  var s = v.toStringAsFixed(6);
  while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}
