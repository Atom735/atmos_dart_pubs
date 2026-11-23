part of 'vector_graphics_xml.dart';

extension VgXmlElementXGradientItem on XmlElement {
  VgGradientItem? asVgGradientItem(double? opacity) {
    if (fullCheck(
      'item',
      const {'android:color', 'android:offset'},
      const {},
    )) return null;
    var color = getColor('android:color');
    final offset = getDouble('android:offset');
    if (color == null || offset == null) {
      addError('Invalid gradient item');
      return null;
    }
    if (opacity != null) color = color.blendOpacity(opacity);
    return VgGradientItem(color: color, offset: offset);
  }
}
