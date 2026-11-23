part of 'vector_graphics_xml.dart';

extension VgXmlElementXGradient on XmlElement {
  VgGradient? asVgGradient(double? alpha) {
    if (fullCheck(
      'gradient',
      const <String>{
        'android:type',
        // linear
        'android:startX',
        'android:startY',
        'android:endX',
        'android:endY',
        // radial
        'android:centerX',
        'android:centerY',
        'android:gradientRadius',
      },
      const {'item'},
    )) return null;

    final colors = <VgColor>[];
    final offsets = <double>[];

    final type = attr('android:type');

    for (final child in childElements) {
      if (child.tName == 'item') {
        final item = child.asVgGradientItem(alpha);
        if (item != null) {
          colors.add(item.color);
          offsets.add(item.offset);
        }
      }
    }

    final width = decoder.width!;
    final height = decoder.height!;
    double v(String name) => getDouble(name)!;

    double w(String name) => (v(name) * 2 - width) / width;
    double h(String name) => (v(name) * 2 - height) / height;
    if (type == 'linear') {
      final startX = w('android:startX');
      final startY = h('android:startY');
      final endX = w('android:endX');
      final endY = h('android:endY');
      return VgGradientLinear(
        id: '',
        from: VgPoint(startX, startY),
        to: VgPoint(endX, endY),
        colors: colors,
        offsets: offsets,
      );
    } else if (type == 'radial') {
      final centerX = w('android:centerX');
      final centerY = h('android:centerY');
      final gradientRadius = v('android:gradientRadius');
      return VgGradientRadial(
        id: '',
        center: VgPoint(centerX, centerY),
        radius: gradientRadius / math.min(width, height),
        colors: colors,
        offsets: offsets,
      );
    } else {
      addError('Invalid type of gradient: $type');
      return null;
    }
  }

  /// Парсит SVG linearGradient/radialGradient в VgGradient (objectBoundingBox 0–1 → from/to -1..1).
  VgGradient? asVgGradientFromSvg(double? fillAlpha) {
    final defs = svgGradientDefs;
    if (defs == null) return null;

    double? parseUnit(String? v) {
      if (v == null) return null;
      final s = v.trim();
      if (s.isEmpty) return null;
      if (s.endsWith('%')) {
        final n = double.tryParse(s.substring(0, s.length - 1));
        return n != null ? n / 100 : null;
      }
      return double.tryParse(s);
    }

    final colors = <VgColor>[];
    final offsets = <double>[];

    for (final child in childElements) {
      if (child.name.qualified != 'stop') continue;
      final offset = parseUnit(child.getAttribute('offset'));
      if (offset == null) continue;
      var c = child.getColor('stop-color');
      if (c == null) c = child.getColor('color');
      if (c == null) continue;
      final opacity = child.getDouble('stop-opacity');
      if (opacity != null) c = c.blendOpacity(opacity);
      if (fillAlpha != null) c = c.blendOpacity(fillAlpha);
      colors.add(c);
      offsets.add(offset.clamp(0.0, 1.0));
    }

    if (colors.isEmpty) return null;

    final width = decoder.width ?? 1;
    final height = decoder.height ?? 1;
    final gradientUnits = getAttribute('gradientUnits') ?? 'objectBoundingBox';

    double toNorm(double v) => (v * 2 - 1);
    double toNormX(double v) => gradientUnits == 'userSpaceOnUse' ? (v * 2 / width - 1) : toNorm(v);
    double toNormY(double v) => gradientUnits == 'userSpaceOnUse' ? (v * 2 / height - 1) : toNorm(v);

    if (name.qualified == 'linearGradient') {
      final x1 = parseUnit(getAttribute('x1')) ?? 0;
      final y1 = parseUnit(getAttribute('y1')) ?? 0;
      final x2 = parseUnit(getAttribute('x2')) ?? 1;
      final y2 = parseUnit(getAttribute('y2')) ?? 0;
      return VgGradientLinear(
        id: '',
        from: VgPoint(toNormX(x1), toNormY(y1)),
        to: VgPoint(toNormX(x2), toNormY(y2)),
        colors: colors,
        offsets: offsets,
      );
    }

    if (name.qualified == 'radialGradient') {
      final cx = parseUnit(getAttribute('cx')) ?? 0.5;
      final cy = parseUnit(getAttribute('cy')) ?? 0.5;
      final r = parseUnit(getAttribute('r')) ?? 0.5;
      final fx = parseUnit(getAttribute('fx'));
      final fy = parseUnit(getAttribute('fy'));
      VgPoint? focal;
      if (fx != null && fy != null) focal = VgPoint(toNormX(fx), toNormY(fy));
      final radiusNorm = gradientUnits == 'userSpaceOnUse'
          ? (r / math.min(width, height))
          : r * 2;
      return VgGradientRadial(
        id: '',
        center: VgPoint(toNormX(cx), toNormY(cy)),
        radius: radiusNorm,
        focalPoint: focal,
        colors: colors,
        offsets: offsets,
      );
    }

    return null;
  }

  /// Разрешает fill или stroke вида url(#id) в градиент из defs.
  VgGradient? getGradientFromUrl(String attrName, double? alpha) {
    final v = attr(attrName);
    if (v == null) return null;
    final s = v.trim();
    if (!s.toLowerCase().startsWith('url(#')) return null;
    final match = RegExp(r'url\(#([^)]+)\)').firstMatch(s);
    if (match == null) return null;
    final defs = svgGradientDefs;
    if (defs == null) return null;
    final el = defs[match.group(1)];
    return el?.asVgGradientFromSvg(alpha);
  }
}
