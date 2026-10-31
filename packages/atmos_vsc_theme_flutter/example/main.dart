import 'dart:io';

import 'package:atmos_vsc_theme/atmos_vsc_theme_io.dart' show VscThemeIo;
import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter/material.dart';

/// Tiny demo: load a VS Code theme JSON and apply it as [ThemeData].
///
/// Run from package root:
/// `flutter run -t example/main.dart -d windows`
void main() {
  final themeFile = File(
    '../atmos_vsc_theme/lib/themes/defaults/dark_modern.json',
  );
  final theme = VscThemeIo.loadColorThemeFile(themeFile);

  runApp(
    MaterialApp(
      title: 'atmos_vsc_theme_flutter',
      theme: theme.toThemeData(),
      home: Scaffold(
        appBar: AppBar(title: Text(theme.name ?? 'Theme')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.palette),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('editor.background: ${theme.editorBackground?.toHex()}'),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Input'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
