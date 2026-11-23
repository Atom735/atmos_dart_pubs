import 'dart:io';

import 'package:args/args.dart';
import 'package:atmos_vg_gen/atmos_vg_gen.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Directory with *.svg files',
      mandatory: true,
    )
    ..addOption(
      'out',
      abbr: 'o',
      help: 'Output directory for generated Dart',
      mandatory: true,
    )
    ..addOption(
      'library',
      defaultsTo: 'vg_assets',
      help: 'library name / basename without .dart',
    )
    ..addOption(
      'class',
      defaultsTo: 'VgAssets',
      help: 'Public accessor class name',
    )
    ..addOption(
      'prefix',
      defaultsTo: '',
      help: 'Static field prefix (e.g. ic_)',
    )
    ..addOption(
      'style',
      allowed: ['dart', 'flutter'],
      defaultsTo: 'flutter',
      help: 'Emit style',
    )
    ..addFlag(
      'preview',
      defaultsTo: true,
      help: 'Also write preview.html',
    )
    ..addFlag(
      'recursive',
      abbr: 'r',
      defaultsTo: false,
      help: 'Scan input recursively',
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
    stdout.writeln('Usage: atmos_vg_gen --input <dir> --out <dir> [options]');
    stdout.writeln(parser.usage);
    return;
  }

  final input = Directory(opts['input'] as String);
  final out = Directory(opts['out'] as String);
  final library = opts['library'] as String;
  final className = opts['class'] as String;
  final prefix = opts['prefix'] as String;
  final style = (opts['style'] as String) == 'dart'
      ? VgEmitStyle.dart
      : VgEmitStyle.flutter;
  final withPreview = opts['preview'] as bool;
  final recursive = opts['recursive'] as bool;

  final assets = loadSvgAssetsFromDirectory(input, recursive: recursive);
  if (assets.isEmpty) {
    stderr.writeln('No *.svg files found in ${input.path}');
    exitCode = 1;
    return;
  }

  final result = generateVgLibrary(
    VgGenSpec(
      libraryName: library,
      className: className,
      assets: assets,
      emitStyle: style,
      prefix: prefix,
    ),
    withPreview: withPreview,
  );

  writeVgGenResult(
    result,
    outputDir: out,
    libraryFileName: '$library.dart',
    previewFileName: withPreview ? 'preview.html' : null,
  );

  stdout.writeln(
    'Wrote ${result.assets.length} assets → ${p.normalize(out.path)}'
    '${withPreview ? ' (+ preview.html)' : ''}',
  );
}
