import 'dart:io';

import 'package:atmos_vscode_theme_flutter/atmos_vscode_theme_flutter.dart';
import 'package:flutter/material.dart';

/// Tiny demo: load a VS Code theme JSON and apply it as [ThemeData].
///
/// Run from package root:
/// `flutter run -t example/main.dart -d windows`
void main() {
  final themeFile = File(
    '../atmos_vscode_theme/test/fixtures/dark_modern.json',
  );
  final vscode = VscodeThemeLoader.loadColorThemeFile(themeFile);

  runApp(
    MaterialApp(
      title: 'atmos_vscode_theme_flutter',
      theme: vscode.toThemeData(),
      home: Scaffold(
        appBar: AppBar(title: Text(vscode.name ?? 'Theme')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('editor.background: ${vscode.editorBackground?.toHex()}'),
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
