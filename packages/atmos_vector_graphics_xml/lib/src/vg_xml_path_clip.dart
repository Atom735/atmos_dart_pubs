part of 'vector_graphics_xml.dart';

extension VgXmlElementXPathClip on XmlElement {
  bool get asVgPathClip {
    if (fullCheck(
      'clip-path',
      const {'android:pathData', 'android:fillType'},
      const {},
    )) return false;

    final commands = getPathCommands('android:pathData');
    if (commands == null) {
      addError('Invalid path data for clip-path');
      return false;
    }

    final fillType = getFillType('android:fillType');

    decoder.drawCalls.add(
      VgDrawCallClipPath(
        pathId: decoder.addPath(
          VgPath(fillType ?? VgPathFillType.evenOdd, commands),
        ),
      ),
    );

    return true;
  }
}
