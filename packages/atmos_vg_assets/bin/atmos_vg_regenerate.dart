// ignore_for_file: depend_on_referenced_packages

import 'dart:collection';
import 'dart:io';

import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';
import 'package:atmos_vector_graphics_xml/atmos_vector_graphics_xml.dart';

final dirIcons = Directory('lib/src/icons');
final dirPictures = Directory('lib/src/pictures');

final resIcons = SplayTreeMap<String, (VgContainer, String, String)>();
final resPictures = SplayTreeMap<String, (VgContainer, String, String)>();

void _convertIcons(File file) {
  final fileName = file.uri.pathSegments.last;
  final fileExt = fileName.split('.').last.toLowerCase();
  if (fileExt != 'svg') return;
  final iconName = fileName.split('.')[1].toLowerCase();
  final vg = VgSvgDecoder.convertFromSvg(file.readAsStringSync());
  if (vg == null) return;
  final fileOutName = 'src/icons/$fileName.g.dart';
  resIcons[fileName] = (
    vg,
    '''
  static const ic_$iconName = //
      _$iconName.\$class;''',
    "part '$fileOutName';",
  );
  File('lib/$fileOutName').writeAsStringSync(generateIconDartData(
    fileName: fileName,
    iconName: iconName,
    bytes: vg.toBytes(),
  ));
}

void _convertPictures(File file) {
  final fileName = file.uri.pathSegments.last;
  final fileExt = fileName.split('.').last.toLowerCase();
  if (fileExt != 'svg') return;
  final baseName = fileName.split('.')[1].toLowerCase();
  final picName = baseName;
  final vg = VgSvgDecoder.convertFromSvg(file.readAsStringSync());
  if (vg == null) return;
  final fileOutName = 'src/pictures/$fileName.g.dart';
  resPictures[fileName] = (
    vg,
    '''
  static const pic_$picName = //
      _pic_$picName.\$class;''',
    "part '$fileOutName';",
  );
  File('lib/$fileOutName').writeAsStringSync(generatePictureDartData(
    fileName: fileName,
    dartName: picName,
    bytes: vg.toBytes(),
  ));
}

void main(List<String> args) {
  if (dirIcons.existsSync()) {
    dirIcons.listSync().whereType<File>().forEach(_convertIcons);
  }
  if (dirPictures.existsSync()) {
    dirPictures.listSync().whereType<File>().forEach(_convertPictures);
  }
  regenerateIcons();
  regeneratePictures();
}

String generateIconDartData({
  required String fileName,
  required String iconName,
  required List<int> bytes,
}) {
  var k = 0;
  String toStr(List<int> bytes) {
    k += bytes.length;
    return '    ' +
        bytes
            .map((e) => '0x' + e.toRadixString(16).padLeft(2, '0') + ', ')
            .join() +
        '// $k';
  }

  final sb = StringBuffer();
  var i = 0;
  for (; i + 8 < bytes.length; i += 8) {
    sb.write(toStr(bytes.sublist(i, i + 8)) + '\n');
  }
  sb.write(toStr(bytes.sublist(i)));

  return '''
// ignore_for_file: camel_case_types

/// Автоматически сгенерированный файл.
/// Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
/// Не редактируйте его вручную.
part of '../../atmos_vg_icons.dart';

/// Сгенерировано из: `$fileName`
final class _$iconName extends AtmosIconsVgBase {
  const _$iconName() : super();

  static final \$vgContainer = VgContainer.fromBytes(\$bytes);
  static const \$class = _$iconName();
  static final \$picture = \$class.getPicture();
  @override
  Picture get picture => \$picture;

  @override
  VgContainer get vgContainer => \$vgContainer;

  static const \$bytes = [
$sb
  ];
}
''';
}

String generatePictureDartData({
  required String fileName,
  required String dartName,
  required List<int> bytes,
}) {
  var k = 0;
  String toStr(List<int> bytes) {
    k += bytes.length;
    return '    ' +
        bytes
            .map((e) => '0x' + e.toRadixString(16).padLeft(2, '0') + ', ')
            .join() +
        '// $k';
  }

  final sb = StringBuffer();
  var i = 0;
  for (; i + 8 < bytes.length; i += 8) {
    sb.write(toStr(bytes.sublist(i, i + 8)) + '\n');
  }
  sb.write(toStr(bytes.sublist(i)));

  return '''
// ignore_for_file: camel_case_types

/// Автоматически сгенерированный файл.
/// Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
/// Не редактируйте его вручную.
part of '../../atmos_vg_pictures.dart';

/// Сгенерировано из: `$fileName`
final class _pic_$dartName extends AtmosPicturesVgBase {
  const _pic_$dartName() : super();

  static final \$vgContainer = VgContainer.fromBytes(\$bytes);
  static const \$class = _pic_$dartName();
  static final \$picture = \$class.getPicture();
  @override
  Picture get picture => \$picture;

  @override
  VgContainer get vgContainer => \$vgContainer;

  static const \$bytes = [
$sb
  ];
}
''';
}

void regenerateIcons() {
  _regenerateFile(
    file: File('lib/atmos_vg_icons.dart'),
    res: resIcons,
  );
}

void regeneratePictures() {
  _regenerateFile(
    file: File('lib/atmos_vg_pictures.dart'),
    res: resPictures,
  );
}

void _regenerateFile({
  required File file,
  required SplayTreeMap<String, (VgContainer, String, String)> res,
}) {
  if (!file.existsSync()) return;
  final content = file.readAsStringSync();

  final i0 = content.indexOf('### GENERATED_START_PARTS ###');
  final i1 = content.indexOf('### GENERATED_END_PARTS ###') + 27 + 1;

  final i2 = content.indexOf('### GENERATED_START_STATICS ###');
  final i3 = content.indexOf('### GENERATED_END_STATICS ###') + 29 + 1;

  if (i0 < 0 || i1 <= i0 || i2 < 0 || i3 <= i2) return;

  final sParts = '''
### GENERATED_START_PARTS ###
// Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
// Не редактируйте эту секцию вручную.
${res.entries.map((e) => e.value.$3).join('\n')}
// ### GENERATED_END_PARTS ###
''';

  final sStatic = '''
### GENERATED_START_STATICS ###
  // Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
  // Не редактируйте эту секцию вручную.
${res.entries.map((e) => e.value.$2).join('\n')}
  // ### GENERATED_END_STATICS ###
''';

  file.writeAsStringSync(
    content.substring(0, i0) +
        sParts +
        content.substring(i1, i2) +
        sStatic +
        content.substring(i3),
  );
}
