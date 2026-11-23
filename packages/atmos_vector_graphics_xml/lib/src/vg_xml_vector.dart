part of 'vector_graphics_xml.dart';

extension VgXmlElementXVector on XmlElement {
  /// Преобразование XML в векторный объект.
  bool get asVgVectorXml {
    if (fullCheck(
      'vector',
      const {
        'android:width',
        'android:height',
        'xmlns:android',
        'xmlns:aapt',
        'android:viewportWidth',
        'android:viewportHeight',
      },
      VgXmlElementXGroup.childNamesInVgGroup,
    )) return false;

    final width = getDouble('android:width');
    final height = getDouble('android:height');
    final viewportWidth = getDouble('android:viewportWidth');
    final viewportHeight = getDouble('android:viewportHeight');

    if (width == null ||
        height == null ||
        viewportWidth == null ||
        viewportHeight == null) {
      addError('Invalid vector element');
      return false;
    }

    if (width != viewportWidth || height != viewportHeight) {
      addError('Width and height must be equal to viewport width and height');
      return false;
    }

    decoder.width = width;
    decoder.height = height;
    return asVgGroupChildrensXml;
  }

  /// Разрешённые дочерние элементы SVG корня.
  static const childNamesInVgSvg = {
    'path', 'rect', 'g', 'defs', 'ellipse', 'circle',
  };

  /// Преобразование SVG в векторный объект.
  /// Размер берётся из viewBox (координатная система); width/height корня могут отличаться.
  bool get asVgVectorSvg {
    if (checkName('svg')) return false;
    if (checkChilds(childNamesInVgSvg)) return false;

    final viewportWidth = getDouble('viewBox', 2);
    final viewportHeight = getDouble('viewBox', 3);

    if (viewportWidth == null || viewportHeight == null) {
      addError('SVG requires viewBox with width and height');
      return false;
    }

    decoder.width = viewportWidth;
    decoder.height = viewportHeight;
    return asVgGroupChildrensSvg;
  }
}
