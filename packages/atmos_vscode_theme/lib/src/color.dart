import 'dart:math' as math;

/// CSS-style hex color as used in VS Code themes (`#RGB` … `#RRGGBBAA`).
///
/// ## ENG
/// Channels are 0–255. [alpha] defaults to 255 when the hex omits alpha.
///
/// ## RU
/// Каналы 0–255. [alpha] = 255, если в hex нет альфы.
class VscodeColor {
  /// Fully opaque black.
  const VscodeColor(this.red, this.green, this.blue, [this.alpha = 255]);

  /// Red channel `0…255`.
  final int red;

  /// Green channel `0…255`.
  final int green;

  /// Blue channel `0…255`.
  final int blue;

  /// Alpha channel `0…255`.
  final int alpha;

  /// Parses `#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` (leading `#` optional).
  ///
  /// Returns `null` if [source] is not a valid hex color.
  static VscodeColor? tryParse(String source) {
    var s = source.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length != 3 && s.length != 4 && s.length != 6 && s.length != 8) {
      return null;
    }
    int? nibble(int i) {
      final c = s.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) return c - 0x30;
      if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10;
      if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10;
      return null;
    }

    int? bytePair(int i) {
      final hi = nibble(i);
      final lo = nibble(i + 1);
      if (hi == null || lo == null) return null;
      return (hi << 4) | lo;
    }

    if (s.length == 3 || s.length == 4) {
      final r = nibble(0);
      final g = nibble(1);
      final b = nibble(2);
      if (r == null || g == null || b == null) return null;
      final a = s.length == 4 ? nibble(3) : 0xF;
      if (a == null) return null;
      return VscodeColor(r * 17, g * 17, b * 17, a * 17);
    }

    final r = bytePair(0);
    final g = bytePair(2);
    final b = bytePair(4);
    if (r == null || g == null || b == null) return null;
    final a = s.length == 8 ? bytePair(6) : 255;
    if (a == null) return null;
    return VscodeColor(r, g, b, a);
  }

  /// Like [tryParse], but throws [FormatException] on invalid input.
  static VscodeColor parse(String source) {
    final c = tryParse(source);
    if (c == null) {
      throw FormatException('Invalid VS Code color: $source');
    }
    return c;
  }

  /// Relative luminance in `0…1` (sRGB, WCAG-style).
  double get luminance {
    double lin(int channel) {
      final v = channel / 255.0;
      return v <= 0.03928
          ? v / 12.92
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * lin(red) + 0.7152 * lin(green) + 0.0722 * lin(blue);
  }

  /// `true` when [luminance] is below `0.5` (typically a dark UI color).
  bool get isDark => luminance < 0.5;

  /// `#RRGGBB` or `#RRGGBBAA` when alpha is not opaque.
  String toHex({bool includeHash = true}) {
    String h2(int v) => v.toRadixString(16).padLeft(2, '0');
    final body = alpha == 255
        ? '${h2(red)}${h2(green)}${h2(blue)}'
        : '${h2(red)}${h2(green)}${h2(blue)}${h2(alpha)}';
    return includeHash ? '#$body' : body;
  }

  @override
  String toString() => 'VscodeColor(${toHex()})';

  @override
  bool operator ==(Object other) =>
      other is VscodeColor &&
      other.red == red &&
      other.green == green &&
      other.blue == blue &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);
}
