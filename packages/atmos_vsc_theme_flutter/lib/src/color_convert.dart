import 'dart:ui' show Color;

import 'package:atmos_vsc_theme/atmos_vsc_theme.dart';

/// Converts [VscColor] to Flutter [Color].
///
/// ## ENG
/// Alpha is taken from the theme hex when present.
///
/// ## RU
/// Альфа берётся из hex темы, если задана.
extension VscColorToFlutter on VscColor {
  /// Flutter [Color] with the same RGBA channels.
  Color toFlutterColor() => Color.fromARGB(alpha, red, green, blue);
}

/// Nullable [VscColor] → Flutter [Color].
extension VscColorNullableToFlutter on VscColor? {
  /// Flutter [Color], or `null` when this is `null`.
  Color? toFlutterColor() => this?.toFlutterColor();
}
