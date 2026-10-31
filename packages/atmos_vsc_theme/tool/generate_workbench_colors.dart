// ignore_for_file: avoid_print
/// Generates typed workbench color accessors from bundled theme JSON keys.
///
/// Run from package root:
/// `dart run tool/generate_workbench_colors.dart`
library;

import 'dart:io';

import 'package:atmos_jsonc/atmos_jsonc.dart';

void main() {
  final keys = <String>{};
  final themesDir = Directory('lib/themes');
  if (!themesDir.existsSync()) {
    stderr.writeln('lib/themes not found — run from package root');
    exitCode = 1;
    return;
  }

  for (final file in themesDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))) {
    final decoded = jsoncDecode(file.readAsStringSync());
    if (decoded is! Map) continue;
    final colors = decoded['colors'];
    if (colors is! Map) continue;
    keys.addAll(colors.keys.cast<String>());
  }

  final sorted = keys.toList()..sort();
  final root = _Node.root();
  for (final key in sorted) {
    root.insert(key.split('.'), key);
  }

  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln(
      '// ignore_for_file: prefer_const_constructors, unused_element, '
      'lines_longer_than_80_chars',
    )
    ..writeln(
      '// Source: dart run tool/generate_workbench_colors.dart',
    )
    ..writeln('// Keys: ${sorted.length} (from lib/themes/**/*.json)')
    ..writeln()
    ..writeln("import '../color.dart';")
    ..writeln()
    ..writeln('/// Typed accessors for VS Code / Cursor workbench colors.')
    ..writeln('///')
    ..writeln('/// ## ENG')
    ..writeln(
      '/// Example: `theme.colors.editor.background` → `VscColor?`.',
    )
    ..writeln('/// Missing keys are `null`. Use [map] / `[]` for raw lookup.')
    ..writeln('///')
    ..writeln('/// ## RU')
    ..writeln(
      '/// Пример: `theme.colors.editor.background` → `VscColor?`.',
    )
    ..writeln('/// Нет ключа — `null`. Сырой доступ: [map] / `[]`.')
    ..writeln('class VscWorkbenchColors {')
    ..writeln('  /// Wraps a resolved workbench color map.')
    ..writeln('  const VscWorkbenchColors(this.map);')
    ..writeln()
    ..writeln('  /// Underlying merged color map.')
    ..writeln('  final Map<String, VscColor> map;')
    ..writeln()
    ..writeln('  /// Looks up a workbench color by full key.')
    ..writeln('  VscColor? operator [](String key) => map[key];')
    ..writeln();

  _writeMembers(out, root, 'VscWorkbenchColors', isRoot: true);

  out.writeln('}');
  out.writeln();

  _writeGroupClasses(out, root);

  const path = 'lib/src/generated/workbench_colors.g.dart';
  Directory('lib/src/generated').createSync(recursive: true);
  var source = out.toString();
  if (!source.endsWith('\n')) source = '$source\n';
  File(path).writeAsStringSync(source);
  print('Wrote $path (${sorted.length} keys)');
}

void _writeMembers(
  StringBuffer out,
  _Node node,
  String ownerClass, {
  required bool isRoot,
}) {
  final leafEntries = node.children.entries
      .where((e) => e.value.isLeaf)
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final groupEntries = node.children.entries
      .where((e) => !e.value.isLeaf)
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  for (final e in leafEntries) {
    final getter = _dartIdent(e.key);
    final key = e.value.fullKey!;
    out
      ..writeln('  /// `$key`.')
      ..writeln("  VscColor? get $getter => map['$key'];")
      ..writeln();
  }

  for (final e in groupEntries) {
    final getter = _dartIdent(e.key);
    final className = _groupClassName(e.value);
    out
      ..writeln('  /// Color group `${e.value.pathLabel}`.')
      ..writeln(
        '  $className get $getter => $className(map);',
      )
      ..writeln();
  }
}

void _writeGroupClasses(StringBuffer out, _Node root) {
  final groups = <_Node>[];
  void walk(_Node n) {
    for (final child in n.children.values) {
      if (!child.isLeaf) {
        groups.add(child);
        walk(child);
      }
    }
  }

  walk(root);
  groups.sort((a, b) => a.pathLabel.compareTo(b.pathLabel));

  for (final node in groups) {
    final className = _groupClassName(node);
    out
      ..writeln('/// Workbench colors under `${node.pathLabel}.…`.')
      ..writeln('class $className {')
      ..writeln('  /// Creates a group view over [map].')
      ..writeln('  const $className(this.map);')
      ..writeln()
      ..writeln('  /// Underlying merged color map.')
      ..writeln('  final Map<String, VscColor> map;')
      ..writeln();
    _writeMembers(out, node, className, isRoot: false);
    out.writeln('}');
    out.writeln();
  }
}

String _groupClassName(_Node node) {
  final parts = node.segments.map(_pascal).join();
  return 'VscWorkbench${parts}Colors';
}

String _pascal(String segment) {
  final id = _dartIdent(segment);
  if (id.isEmpty) return 'X';
  return id[0].toUpperCase() + id.substring(1);
}

/// Valid Dart getter / field identifier from a theme key segment.
String _dartIdent(String raw) {
  var s = raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  if (s.isEmpty) s = 'value';
  if (RegExp(r'^[0-9]').hasMatch(s)) s = '\$$s';
  const reserved = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
  };
  if (reserved.contains(s)) return '${s}_';
  return s;
}

class _Node {
  _Node._(this.segments);

  factory _Node.root() => _Node._(const []);

  final List<String> segments;
  final Map<String, _Node> children = {};
  String? fullKey;

  bool get isLeaf => fullKey != null && children.isEmpty;

  String get pathLabel => segments.join('.');

  void insert(List<String> parts, String key) {
    if (parts.isEmpty) {
      fullKey = key;
      return;
    }
    final head = parts.first;
    final child = children.putIfAbsent(
      head,
      () => _Node._([...segments, head]),
    );
    child.insert(parts.sublist(1), key);
  }
}
