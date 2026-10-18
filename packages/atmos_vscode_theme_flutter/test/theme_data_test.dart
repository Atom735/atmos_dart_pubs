import 'dart:io';

import 'package:atmos_vscode_theme_flutter/atmos_vscode_theme_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark_modern maps to dark ColorScheme', () {
    final file = File(
      '../atmos_vscode_theme/test/fixtures/dark_modern.json',
    );
    final theme = VscodeThemeLoader.loadColorThemeFile(file);
    final scheme = theme.toColorScheme();

    expect(scheme.brightness, Brightness.dark);
    expect(scheme.surface.opacity, greaterThan(0));
    expect(theme.toThemeData().scaffoldBackgroundColor, isNotNull);
  });
}
