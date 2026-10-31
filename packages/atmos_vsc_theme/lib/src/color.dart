import 'dart:math' as math;

/// CSS-style hex color as used in VS Code / Cursor themes (`#RGB` … `#RRGGBBAA`).
///
/// ## ENG
/// Channels are 0–255. [alpha] defaults to 255 when the hex omits alpha.
/// Includes blend / mix / contrast helpers for theme work.
///
/// ## RU
/// Каналы 0–255. [alpha] = 255, если в hex нет альфы.
/// Есть хелперы blend / mix / contrast для работы с темами.
class VscColor {
  /// Fully opaque black.
  const VscColor(this.red, this.green, this.blue, [this.alpha = 255]);

  /// Opaque white.
  static const white = VscColor(255, 255, 255);

  /// Opaque black.
  static const black = VscColor(0, 0, 0);

  /// Fully transparent (any RGB, alpha 0).
  static const transparent = VscColor(0, 0, 0, 0);

  /// Red channel `0…255`.
  final int red;

  /// Green channel `0…255`.
  final int green;

  /// Blue channel `0…255`.
  final int blue;

  /// Alpha channel `0…255`.
  final int alpha;

  /// Opacity in `0…1`.
  double get opacity => alpha / 255.0;

  /// `true` when [alpha] is 255.
  bool get isOpaque => alpha == 255;

  /// `true` when [alpha] is 0.
  bool get isTransparent => alpha == 0;

  /// Same RGB with alpha 255.
  VscColor get opaque => alpha == 255 ? this : VscColor(red, green, blue);

  /// Parses `#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` (leading `#` optional).
  ///
  /// Returns `null` if [source] is not a valid hex color.
  static VscColor? tryParse(String source) {
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
      return VscColor(r * 17, g * 17, b * 17, a * 17);
    }

    final r = bytePair(0);
    final g = bytePair(2);
    final b = bytePair(4);
    if (r == null || g == null || b == null) return null;
    final a = s.length == 8 ? bytePair(6) : 255;
    if (a == null) return null;
    return VscColor(r, g, b, a);
  }

  /// Like [tryParse], but throws [FormatException] on invalid input.
  static VscColor parse(String source) {
    final c = tryParse(source);
    if (c == null) {
      throw FormatException('Invalid theme color: $source');
    }
    return c;
  }

  /// Linear interpolation between [a] and [b] (`t` in `0…1`).
  // ignore: prefer_constructors_over_static_methods
  static VscColor lerp(VscColor a, VscColor b, double t) {
    final x = t.clamp(0.0, 1.0);
    int ch(int from, int to) => (from + (to - from) * x).round().clamp(0, 255);
    return VscColor(
      ch(a.red, b.red),
      ch(a.green, b.green),
      ch(a.blue, b.blue),
      ch(a.alpha, b.alpha),
    );
  }

  /// Copy with a new alpha channel `0…255`.
  VscColor withAlpha(int alpha) =>
      VscColor(red, green, blue, alpha.clamp(0, 255));

  /// Copy with opacity `0…1`.
  VscColor withOpacity(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

  /// Source-over alpha composite of `this` on top of opaque [background].
  ///
  /// ## ENG
  /// Typical use: resolve `#RRGGBBAA` selection/border against
  /// `editor.background`. Result is opaque.
  ///
  /// ## RU
  /// Типичный кейс: свести полупрозрачный selection/border на
  /// `editor.background`. Результат непрозрачный.
  VscColor blendOver(VscColor background) {
    if (isOpaque) return this;
    if (isTransparent) return background.opaque;
    final fgA = opacity;
    final bgA = background.opacity;
    final outA = fgA + bgA * (1 - fgA);
    if (outA <= 0) return transparent;
    int ch(int fg, int bg) =>
        ((fg * fgA + bg * bgA * (1 - fgA)) / outA).round().clamp(0, 255);
    return VscColor(
      ch(red, background.red),
      ch(green, background.green),
      ch(blue, background.blue),
      (outA * 255).round().clamp(0, 255),
    );
  }

  /// Mix with [other] (`amount` = weight of [other], `0…1`).
  VscColor mix(VscColor other, [double amount = 0.5]) =>
      VscColor.lerp(this, other, amount);

  /// Lighten toward white by [amount] (`0…1`).
  VscColor lighten([double amount = 0.1]) => mix(white, amount);

  /// Darken toward black by [amount] (`0…1`).
  VscColor darken([double amount = 0.1]) => mix(black, amount);

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

  /// WCAG contrast ratio against [other] (`1…21`), using opaque RGB.
  double contrastRatio(VscColor other) {
    final l1 = opaque.luminance;
    final l2 = other.opaque.luminance;
    final bright = l1 > l2 ? l1 : l2;
    final dark = l1 > l2 ? l2 : l1;
    return (bright + 0.05) / (dark + 0.05);
  }

  /// Picks [light] or [dark] for better contrast on `this` as background.
  VscColor onContrast({
    VscColor light = white,
    VscColor dark = black,
  }) {
    final bg = opaque;
    return bg.contrastRatio(light) >= bg.contrastRatio(dark) ? light : dark;
  }

  /// `#RRGGBB` or `#RRGGBBAA` when alpha is not opaque.
  String toHex({bool includeHash = true}) {
    String h2(int v) => v.toRadixString(16).padLeft(2, '0');
    final body = alpha == 255
        ? '${h2(red)}${h2(green)}${h2(blue)}'
        : '${h2(red)}${h2(green)}${h2(blue)}${h2(alpha)}';
    return includeHash ? '#$body' : body;
  }

  @override
  String toString() => 'VscColor(${toHex()})';

  @override
  bool operator ==(Object other) =>
      other is VscColor &&
      other.red == red &&
      other.green == green &&
      other.blue == blue &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);
}
