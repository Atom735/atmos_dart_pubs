part of 'vector_graphics_xml.dart';

extension VgXmlElementXBase on XmlElement {
  /// Имя элемента.
  String get tName => name.qualified;

  /// Декодер.
  VgDecoderBase get decoder => VgDecoderBase.it!;

  /// Реестр clipPath (только для VgSvgDecoder).
  Map<String, XmlElement>? get svgClipPaths =>
      decoder is VgSvgDecoder ? (decoder as VgSvgDecoder).clipPaths : null;

  /// Реестр градиентов из defs (только для VgSvgDecoder).
  Map<String, XmlElement>? get svgGradientDefs =>
      decoder is VgSvgDecoder ? (decoder as VgSvgDecoder).gradientDefs : null;

  /// Получение значения атрибута.
  String? attr(String name) => getAttribute(name);

  /// Добавление лога ошибки для всех предков.
  void addError(String message) {
    decoder.addError(message);
    decoder.addError('IN>> $tName');
    for (final e in ancestorElements) {
      decoder.addError('  >> ${e.tName}');
    }
  }

  /// Проверка пересечения набора атрибутов.
  ///
  /// Возвращает true, если есть атрибуты,
  /// которые не входят в набор [input].
  bool checkAttr(Set<String> input) {
    final result = <String>{};
    for (final attribute in attributes) {
      result.add(attribute.name.qualified);
    }
    final dif = result.difference(input);
    if (dif.isNotEmpty) {
      addError('Invalid attribute value in `$tName`');
      addError(dif.join(', '));
      return true;
    }
    return false;
  }

  /// Проверка имени элемента.
  bool checkName(String name) {
    if (tName != name) {
      addError('Invalid element name in `$tName`');
      return true;
    }
    return false;
  }

  /// Проверка наличия дочерних элементов.
  bool checkChilds(Set<String> input) {
    final result = <String>{};
    for (final child in childElements) {
      result.add(child.tName);
    }
    final dif = result.difference(input);
    if (dif.isNotEmpty) {
      addError('Invalid childs in `$tName`');
      addError(dif.join(', '));
      return true;
    }
    return false;
  }

  /// Полная проверка элемента.
  bool fullCheck(String name, Set<String> attrs, Set<String> childs) =>
      checkName(name) || checkAttr(attrs) || checkChilds(childs);

  /// Получение значения атрибута в виде типа [T].
  T? attrMapped<T>(
    String name,
    Map<String, T> mapper,
  ) {
    final i = attr(name);
    if (i == null) return null;
    if (mapper.containsKey(i)) {
      return mapper[i];
    }
    addError('Invalid attribute value in `$name` (${attr(name)})');
    return null;
  }
}
