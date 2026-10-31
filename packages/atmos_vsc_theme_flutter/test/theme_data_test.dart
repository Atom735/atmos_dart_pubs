import 'dart:io';

import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart' show VscThemeIo;
import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark_modern maps to dark ColorScheme', () {
    final file = File(
      '../atmos_vsc_theme/lib/themes/defaults/dark_modern.json',
    );
    final theme = VscThemeIo.loadColorThemeFile(file);
    final scheme = theme.toColorScheme();
    final data = theme.toThemeData();

    expect(scheme.brightness, Brightness.dark);
    expect(scheme.surface.opacity, greaterThan(0));
    expect(data.scaffoldBackgroundColor, isNotNull);
    expect(data.textSelectionTheme.cursorColor, isNotNull);
    expect(data.floatingActionButtonTheme.backgroundColor, isNotNull);
  });
}
