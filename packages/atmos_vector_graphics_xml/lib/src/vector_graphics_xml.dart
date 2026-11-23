/// Библиотека векторной графики из XML (Android Drawable) файла.

library atmos_vector_graphics_xml;

import 'dart:convert';
import 'dart:math' as math;

import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';

import 'package:xml/xml.dart';

part 'vg_xml_attr.dart';
part 'vg_xml_base.dart';
part 'vg_xml_gradient.dart';
part 'vg_xml_gradient_item.dart';
part 'vg_xml_group.dart';
part 'vg_xml_path.dart';
part 'vg_xml_path_clip.dart';
part 'vg_xml_path_coms.dart';
part 'vg_xml_svg_shapes.dart';
part 'vg_xml_vector.dart';

extension VgXmlElementX on XmlElement {}

class VgXmlDecoder extends VgDecoderBase
    with Converter<XmlElement, VgContainer?> {
  VgXmlDecoder();

  @override
  void addError(String message) {
    errors.writeln(message);
    // Errors are collected in [errors].
  }

  @override
  VgContainer? convert(XmlElement input) => run(() {
        final element = input;
        try {
          if (!element.asVgVectorXml) {
            addError('Invalid vector element');
            return null;
          }
        } on Object {
          addError('Invalid vector element');
          return null;
        }
        return asContainer;
      });

  static VgContainer? convertFromXml(String xml) =>
      VgXmlDecoder().convert(XmlDocument.parse(xml).rootElement);
}

class VgSvgDecoder extends VgDecoderBase
    with Converter<XmlElement, VgContainer?> {
  VgSvgDecoder();

  /// Реестр clipPath по id (url(#id)).
  final Map<String, XmlElement> clipPaths = {};

  /// Реестр градиентов по id (fill="url(#id)").
  final Map<String, XmlElement> gradientDefs = {};

  @override
  void addError(String message) {
    errors.writeln(message);
    // Errors are collected in [errors].
  }

  void _collectClipPaths(XmlElement root) {
    for (final defs in root.findAllElements('defs')) {
      for (final clipPath in defs.findElements('clipPath')) {
        final id = clipPath.getAttribute('id');
        if (id != null) clipPaths[id] = clipPath;
      }
    }
  }

  void _collectGradientDefs(XmlElement root) {
    for (final defs in root.findAllElements('defs')) {
      for (final el in defs.childElements) {
        final name = el.name.qualified;
        if (name == 'linearGradient' || name == 'radialGradient') {
          final id = el.getAttribute('id');
          if (id != null) gradientDefs[id] = el;
        }
      }
    }
  }

  @override
  VgContainer? convert(XmlElement input) => run(() {
        clipPaths.clear();
        gradientDefs.clear();
        _collectClipPaths(input);
        _collectGradientDefs(input);
        final element = input;
        try {
          if (!element.asVgVectorSvg) {
            addError('Invalid vector element');
            return null;
          }
        } on Object {
          addError('Invalid vector element');
          return null;
        }
        return asContainer;
      });

  static VgContainer? convertFromSvg(String xml) =>
      VgSvgDecoder().convert(XmlDocument.parse(xml).rootElement);
}
