import 'dart:io';

import 'package:args/args.dart';
import 'package:atmos_icon_font_gen/atmos_icon_font_gen.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Directory with *.svg',
      mandatory: true,
    )
    ..addOption('out-ttf', help: 'Output .ttf path', mandatory: true)
    ..addOption('out-dart', help: 'Output Dart library path', mandatory: true)
    ..addOption('family', defaultsTo: 'AppIcons', help: 'Font family')
    ..addOption('class', defaultsTo: 'AppIcons', help: 'Dart class name')
    ..addOption('package', help: 'IconData.fontPackage')
    ..addOption(
      'codepoint-start',
      defaultsTo: '0xE001',
      help: 'First PUA code point (hex or int)',
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  late ArgResults opts;
  try {
    opts = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }
  if (opts['help'] == true) {
    stdout.writeln(parser.usage);
    return;
  }

  final input = Directory(opts['input'] as String);
  final files = input
      .listSync()
      .whereType<File>()
      .where((f) => p.extension(f.path).toLowerCase() == '.svg')
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    stderr.writeln('No SVG files in ${input.path}');
    exitCode = 1;
    return;
  }

  var cp = _parseInt(opts['codepoint-start'] as String);
  final icons = <IconGlyphSpec>[];
  for (final file in files) {
    final name = p.basenameWithoutExtension(file.path);
    final d = svgDocumentFirstPathD(file.readAsStringSync());
    icons.add(IconGlyphSpec(name: name, codePoint: cp, svgPath: d));
    cp++;
  }

  final result = generateIconFont(
    IconFontSpec(
      fontFamily: opts['family'] as String,
      className: opts['class'] as String,
      fontPackage: opts['package'] as String?,
      icons: icons,
      generatedBy: 'atmos_icon_font_gen',
    ),
  );

  File(opts['out-ttf'] as String)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(result.ttfBytes);
  File(opts['out-dart'] as String)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(result.dartSource);

  stdout.writeln(
    'Wrote ${icons.length} glyphs → ${opts['out-ttf']} + ${opts['out-dart']}',
  );
}

int _parseInt(String raw) {
  final s = raw.trim().toLowerCase();
  if (s.startsWith('0x')) return int.parse(s.substring(2), radix: 16);
  return int.parse(s);
}
