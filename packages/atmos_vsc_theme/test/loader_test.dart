import 'dart:io';

import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart';
import 'package:test/test.dart';

void main() {
  final defaults = Directory('lib/themes/defaults');

  test('loads dark_modern with include chain', () {
    final theme = VscThemeIo.loadColorThemeFile(
      File('${defaults.path}/dark_modern.json'),
    );

    expect(theme.name, 'Default Dark Modern');
    expect(theme.isDark, isTrue);

    expect(theme['editor.background']?.toHex().toLowerCase(), '#1f1f1f');
    expect(theme['editor.foreground'], isNotNull);
    expect(theme.tokenColors.length, greaterThan(20));
    expect(
      theme.semanticTokenColors['newOperator']?.foreground,
      isNotNull,
    );
    expect(theme.semanticHighlighting, isTrue);
  });

  test('loads UTF-8 bytes with include base', () {
    final file = File('${defaults.path}/dark_modern.json');
    final theme = VscThemeIo.loadColorThemeBytes(
      file.readAsBytesSync(),
      includeBase: file.parent,
    );
    expect(theme.name, 'Default Dark Modern');
    expect(theme.editorBackground?.toHex().toUpperCase(), '#1F1F1F');
  });

  test('child colors override parent', () {
    final files = <String, String>{};
    for (final name in ['dark_vs.json', 'dark_plus.json', 'dark_modern.json']) {
      files['./$name'] = File('${defaults.path}/$name').readAsStringSync();
      files[name] = files['./$name']!;
    }

    final leaf = files['./dark_modern.json']!;
    final theme = VscThemeLoader.parseColorTheme(
      leaf,
      resolveInclude: (rel) {
        final key = rel.startsWith('./') ? rel : './$rel';
        return files[key] ?? files[rel]!;
      },
    );

    expect(theme.editorBackground?.toHex().toUpperCase(), '#1F1F1F');
  });

  test('loads 2026 dark include chain', () {
    final theme = VscThemeIo.loadColorThemeFile(
      File('${defaults.path}/2026-dark.json'),
    );
    expect(theme.name, '2026 Dark');
    expect(theme.isDark, isTrue);
    expect(theme.editorBackground, isNotNull);
    expect(theme.tokenColors, isNotEmpty);
  });

  test('async URI include chain resolves per-file base', () async {
    final file = File('${defaults.path}/2026-dark.json');
    final theme = await VscThemeLoader.loadColorThemeUriAsync(
      file.uri,
      readIncludeUri: (uri) async => File.fromUri(uri).readAsStringSync(),
    );
    expect(theme.name, '2026 Dark');
    expect(
      theme.colors.editor.background?.toHex().toUpperCase(),
      '#121314',
    );
    expect(theme.tokenColors.length, greaterThan(20));
  });

  test('theme equality', () {
    final a = VscThemeIo.loadColorThemeFile(
      File('${defaults.path}/dark_modern.json'),
    );
    final b = VscThemeIo.loadColorThemeFile(
      File('${defaults.path}/dark_modern.json'),
    );
    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
  });

  test('loads cursor dark theme', () {
    final theme = VscThemeIo.loadColorThemeFile(
      File(VscBundledThemes.cursorDark.packageLibPath),
    );
    expect(theme.name, contains('Cursor Dark'));
    expect(theme['editor.background'], isNotNull);
  });

  test('bundled theme asset paths are stable', () {
    expect(
      VscBundledThemes.darkModern.assetPath,
      'packages/atmos_vsc_theme/themes/defaults/dark_modern.json',
    );
    expect(VscBundledThemes.all.length, greaterThanOrEqualTo(20));
  });

  test('typed colors.editor.background matches map lookup', () {
    final theme = VscThemeIo.loadColorThemeFile(
      File('${defaults.path}/dark_modern.json'),
    );
    expect(
      theme.colors.editor.background?.toHex().toLowerCase(),
      theme['editor.background']?.toHex().toLowerCase(),
    );
    expect(theme.colors.editor.background, isNotNull);
    expect(theme.colors.activityBar.foreground, isNotNull);
    expect(theme.colorMap['editor.background'], theme.colors.editor.background);
  });

  test('detects circular include', () {
    expect(
      () => VscThemeLoader.parseColorTheme(
        '{"include":"./a.json"}',
        resolveInclude: (_) => '{"include":"./a.json"}',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses semantic token object styles', () {
    final theme = VscThemeLoader.parseColorTheme('''
    {
      "semanticTokenColors": {
        "variable": { "foreground": "#aabbcc", "fontStyle": "italic" },
        "comment": "#112233"
      }
    }
    ''');
    expect(
      theme.semanticTokenColors['variable']?.foreground?.toHex().toLowerCase(),
      '#aabbcc',
    );
    expect(theme.semanticTokenColors['variable']?.fontStyle, 'italic');
    expect(
      theme.semanticTokenColors['comment']?.foreground?.toHex().toLowerCase(),
      '#112233',
    );
  });

  test('null and blank colors clear inherited values', () {
    final theme = VscThemeLoader.parseColorTheme(
      '''
      {
        "include": "base.json",
        "colors": {
          "editor.background": null,
          "editor.foreground": "",
          "sideBar.foreground": "   ",
          "focusBorder": "#ff0000",
          "editor.selectionBackground": "not-a-color"
        }
      }
      ''',
      resolveInclude: (_) => '''
      {
        "colors": {
          "editor.background": "#111111",
          "editor.foreground": "#222222",
          "sideBar.foreground": "#333333",
          "sideBar.background": "#444444",
          "editor.selectionBackground": "#555555"
        }
      }
      ''',
    );

    expect(theme['editor.background'], isNull);
    expect(theme['editor.foreground'], isNull);
    expect(theme['sideBar.foreground'], isNull);
    expect(theme['sideBar.background']?.toHex().toLowerCase(), '#444444');
    expect(theme['focusBorder']?.toHex().toLowerCase(), '#ff0000');
    expect(
      theme['editor.selectionBackground']?.toHex().toLowerCase(),
      '#555555',
    );
  });
}
