part of 'vector_graphics_xml.dart';

extension VgXmlElementXAttr on XmlElement {
  /// Получение значения атрибута в виде числа.
  double? getDouble(String name, [int? index]) {
    var i = attr(name);
    if (i == null) return null;

    if (index != null) {
      final parts = i.split(RegExp(r'[\s,]+'));
      if (index >= parts.length) return null;
      i = parts[index];
    }

    i = i.trim();
    if (i.endsWith('dp')) i = i.substring(0, i.length - 2);
    if (i.endsWith('px')) i = i.substring(0, i.length - 2);
    if (i.endsWith('pt')) i = i.substring(0, i.length - 2);
    if (i.endsWith('em')) i = i.substring(0, i.length - 2);
    try {
      return double.parse(i);
    } on Object {
      addError('Invalid attribute double value in `$name` (${attr(name)})');
      return null;
    }
  }

  static const _namedColors = {
    'white': 'FFFFFFFF', 'black': 'FF000000', 'red': 'FFFF0000',
    'green': 'FF008000', 'blue': 'FF0000FF', 'gray': 'FF808080',
    'grey': 'FF808080', 'currentColor': 'FF000000',
  };

  /// Получение значения атрибута в виде цвета.
  VgColor? getColor(String name) {
    var i = getAttribute(name);
    switch (i) {
      case null:
      case 'none':
        return null;
    }
    i = i.trim().toLowerCase();
    if (_namedColors.containsKey(i)) {
      i = _namedColors[i]!;
      return VgColor(int.parse(i, radix: 16));
    }
    final rgbMatch = RegExp(r'rgb\s*\(\s*(\d+)\s+(\d+)\s+(\d+)\s*\)')
        .firstMatch(i);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!).clamp(0, 255);
      final g = int.parse(rgbMatch.group(2)!).clamp(0, 255);
      final b = int.parse(rgbMatch.group(3)!).clamp(0, 255);
      return VgColor(0xFF000000 | (r << 16) | (g << 8) | b);
    }
    if (i.startsWith('#')) i = i.substring(1);
    if (i.length == 3) i = i.split('').map((e) => '$e$e').join();
    if (i.length == 4) i = i.split('').map((e) => '$e$e').join();
    if (i.length == 6) i = 'FF$i';
    if (i.length != 8) {
      addError('Invalid color value in `$name` (${attr(name)})');
      return null;
    }
    try {
      final color = VgColor(int.parse(i, radix: 16));
      return color;
    } on Object {
      addError('Invalid color value in `$name` (${attr(name)})');
      return null;
    }
  }

  /// Получение значения атрибута в виде типа [VgPathFillType].
  VgPathFillType? getFillType(String name) {
    return attrMapped(
          name,
          const {
            'nonZero': VgPathFillType.nonZero,
            'evenOdd': VgPathFillType.evenOdd,
            'nonzero': VgPathFillType.nonZero,
            'evenodd': VgPathFillType.evenOdd,
          },
        ) ??
        VgPathFillType.nonZero;
  }

  /// Получение значения атрибута в виде типа [VgStrokeCap].
  VgStrokeCap? getStrokeCap(String name) {
    return attrMapped(
          name,
          const {
            'butt': VgStrokeCap.butt,
            'round': VgStrokeCap.round,
            'square': VgStrokeCap.square,
          },
        ) ??
        VgStrokeCap.butt;
  }

  /// Получение значения атрибута в виде типа [VgStrokeJoin].
  VgStrokeJoin? getStrokeJoin(String name) {
    return attrMapped(
          name,
          const {
            'miter': VgStrokeJoin.miter,
            'round': VgStrokeJoin.round,
            'bevel': VgStrokeJoin.bevel,
          },
        ) ??
        VgStrokeJoin.miter;
  }
}
