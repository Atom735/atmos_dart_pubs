import 'package:xml/xml.dart';

import 'element.dart';
import 'errors.dart';
import 'node.dart';
import 'query.dart';
import 'view_box.dart';

/// An editable SVG document rooted at an `<svg>` element.
///
/// Редактируемый SVG-документ с корнем `<svg>`.
class SvgDocument {
  /// Creates a document with [root] (`svg` recommended).
  ///
  /// Создаёт документ с [root] (рекомендуется `svg`).
  SvgDocument(this.root);

  /// Parses [source] as SVG XML.
  ///
  /// Разбирает [source] как SVG XML.
  factory SvgDocument.parse(String source) {
    final XmlDocument xml;
    try {
      xml = XmlDocument.parse(source);
    } on XmlException catch (e) {
      throw SvgFormatException(e.toString());
    }
    final svg = xml.rootElement;
    final local = svg.name.local;
    if (local != 'svg') {
      throw SvgFormatException(
        'Expected root <svg>, got <${svg.name.qualified}>.',
      );
    }
    return SvgDocument(_fromXmlElement(svg));
  }

  /// Root `<svg>` element.
  ///
  /// Корневой элемент `<svg>`.
  final SvgElement root;

  /// `xmlns` on the root, if present.
  ///
  /// `xmlns` корня, если есть.
  String? get xmlns => root.getAttribute('xmlns');

  /// Parsed `viewBox`, or `null` if missing / invalid.
  ///
  /// Разобранный `viewBox` или `null`, если нет / некорректен.
  SvgViewBox? get viewBox {
    final raw = root.getAttribute('viewBox');
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return SvgViewBox.parse(raw);
    } on SvgFormatException {
      return null;
    }
  }

  set viewBox(SvgViewBox? value) {
    if (value == null) {
      root.removeAttribute('viewBox');
    } else {
      root.setAttribute('viewBox', value.toString());
    }
  }

  /// See [SvgElement.getElementById].
  SvgElement? getElementById(String id) => root.getElementById(id);

  /// See [SvgElement.getElementsByTagName].
  List<SvgElement> getElementsByTagName(String name) =>
      root.getElementsByTagName(name);

  /// See [SvgElement.querySelector].
  SvgElement? querySelector(String selector) => root.querySelector(selector);

  /// See [SvgElement.querySelectorAll].
  List<SvgElement> querySelectorAll(String selector) =>
      root.querySelectorAll(selector);

  /// All elements in document order (including [root]).
  ///
  /// Все элементы в порядке документа (включая [root]).
  Iterable<SvgElement> get elements => queryElements(root);

  /// Serializes to an [XmlDocument].
  ///
  /// Сериализует в [XmlDocument].
  XmlDocument toXml({bool pretty = false}) {
    final doc = XmlDocument([_toXmlElement(root)]);
    if (pretty) {
      // xml 6: use XmlDocument toXmlString with pretty
    }
    return doc;
  }

  /// Serializes to an XML string.
  ///
  /// Сериализует в XML-строку.
  String toXmlString({bool pretty = false, String indent = '  '}) {
    return toXml().toXmlString(pretty: pretty, indent: indent);
  }

  @override
  String toString() => 'SvgDocument(${root.name})';
}

SvgElement _fromXmlElement(XmlElement xml) {
  final attrs = <String, String>{};
  for (final a in xml.attributes) {
    // Prefer local name; keep xmlns as "xmlns" / "xmlns:prefix"
    final key = a.name.prefix == null
        ? a.name.local
        : '${a.name.prefix}:${a.name.local}';
    attrs[key] = a.value;
  }
  final el = SvgElement(xml.name.local, attributes: attrs);
  for (final node in xml.children) {
    if (node is XmlElement) {
      el.appendChild(_fromXmlElement(node));
    } else if (node is XmlText) {
      final t = node.value;
      if (t.trim().isNotEmpty) {
        el.appendChild(SvgText(t));
      }
    } else if (node is XmlCDATA) {
      el.appendChild(SvgText(node.value));
    }
  }
  return el;
}

XmlElement _toXmlElement(SvgElement el) {
  final attrs = <XmlAttribute>[
    for (final e in el.attributes.entries)
      XmlAttribute(XmlName(e.key), e.value),
  ];
  final children = <XmlNode>[
    for (final child in el.children)
      if (child is SvgElement)
        _toXmlElement(child)
      else if (child is SvgText)
        XmlText(child.text),
  ];
  return XmlElement(XmlName(el.name), attrs, children);
}
