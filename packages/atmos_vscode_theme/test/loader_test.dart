import 'dart:io';

import 'package:atmos_vscode_theme/atmos_vscode_theme.dart';
import 'package:test/test.dart';

void main() {
  final fixtures = Directory('test/fixtures');

  test('loads dark_modern with include chain', () {
    final theme = VscodeThemeLoader.loadColorThemeFile(
      File('${fixtures.path}/dark_modern.json'),
    );

    expect(theme.name, 'Dark Modern');
    expect(theme.isDark, isTrue);

    // From dark_modern override
    expect(theme['editor.background']?.toHex().toLowerCase(), '#1f1f1f');

    // Inherited from dark_vs (via dark_plus)
    expect(theme['editor.foreground'], isNotNull);

    // tokenColors accumulated across include chain
    expect(theme.tokenColors.length, greaterThan(20));

    // semantic from dark_plus
    expect(theme.semanticTokenColors.containsKey('newOperator'), isTrue);
  });

  test('child colors override parent', () {
    final files = <String, String>{};
    for (final name in ['dark_vs.json', 'dark_plus.json', 'dark_modern.json']) {
      files['./$name'] = File('${fixtures.path}/$name').readAsStringSync();
      files[name] = files['./$name']!;
    }

    final leaf = files['./dark_modern.json']!;
    final theme = VscodeThemeLoader.parseColorTheme(
      leaf,
      resolveInclude: (rel) {
        final key = rel.startsWith('./') ? rel : './$rel';
        return files[key] ?? files[rel]!;
      },
    );

    // dark_vs has #1E1E1E, dark_modern overrides to #1F1F1F
    expect(theme.editorBackground?.toHex().toUpperCase(), '#1F1F1F');
  });

  test('detects circular include', () {
    expect(
      () => VscodeThemeLoader.parseColorTheme(
        '{"include":"./a.json"}',
        resolveInclude: (_) => '{"include":"./a.json"}',
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
