import 'package:flutter/widgets.dart';

import 'vsc_codicon_catalog.dart';

/// A Codicon drawn from the bundled font, at the VS Code 16px grid by default.
///
/// ## ENG
/// [icon] is a constant from `VscCodicons`. Color defaults to [IconTheme].
///
/// ## RU
/// [icon] — константа из `VscCodicons`.
/// Цвет по умолчанию берётся из [IconTheme].
class VscCodicon extends StatelessWidget {
  /// Creates a Codicon from a constant glyph.
  const VscCodicon(
    IconData glyph, {
    super.key,
    this.size = 16,
    this.color,
    this.semanticLabel,
  }) : icon = glyph;

  /// Draws the product icon [ref] (`book`, `$(book)`, `codicon-book`).
  ///
  /// Рисует product icon [ref] (`book`, `$(book)`, `codicon-book`).
  ///
  /// An unknown id keeps [size] as empty space.
  ///
  /// Неизвестный id оставляет пустое место размером [size].
  factory VscCodicon.fromRef(
    String ref, {
    Key? key,
    double size = 16,
    Color? color,
    String? semanticLabel,
  }) {
    final icon = VscCodiconCatalog.resolve(ref);
    if (icon == null) {
      return VscCodicon._empty(key: key, size: size);
    }
    return VscCodicon(
      icon,
      key: key,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? VscCodiconCatalog.normalize(ref),
    );
  }

  const VscCodicon._empty({
    super.key,
    required this.size,
  })  : icon = null,
        color = null,
        semanticLabel = null;

  /// Glyph to draw. Null when [VscCodicon.fromRef] did not resolve.
  ///
  /// Глиф. Null, если [VscCodicon.fromRef] ничего не нашёл.
  final IconData? icon;

  /// Logical pixels. Codicons are designed on a 16×16 grid.
  ///
  /// Логические пиксели. Codicons нарисованы в сетке 16×16.
  final double size;

  /// Tint. Null uses [IconTheme].
  ///
  /// Оттенок. Null — цвет [IconTheme].
  final Color? color;

  /// Accessibility label.
  ///
  /// Подпись для accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final glyph = icon;
    if (glyph == null) {
      return SizedBox.square(dimension: size);
    }
    return Icon(
      glyph,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
