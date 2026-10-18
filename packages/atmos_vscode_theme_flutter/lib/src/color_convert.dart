import 'package:atmos_vscode_theme/atmos_vscode_theme.dart';
import 'package:flutter/material.dart';

/// Converts [VscodeColor] to Flutter [Color].
///
/// ## ENG
/// Alpha is taken from the theme hex when present.
///
/// ## RU
/// Альфа берётся из hex темы, если задана.
extension VscodeColorToFlutter on VscodeColor {
  /// Flutter [Color] with the same RGBA channels.
  Color toFlutterColor() => Color.fromARGB(alpha, red, green, blue);
}
