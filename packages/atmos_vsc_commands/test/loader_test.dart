import 'dart:io';

import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:test/test.dart';

void main() {
  final fixtures = Directory('test/fixtures');

  test('parses keybindings.json with JSONC', () {
    final file = File('${fixtures.path}/keybindings.json');
    final bindings = VscCommandsLoader.loadKeybindingsFile(file);

    expect(bindings, hasLength(4));
    expect(bindings[0].command, 'cursorHome');
    expect(bindings[1].chordParts(), ['ctrl+k', 'ctrl+c']);
    expect(bindings[2].isRemoval, isTrue);
    expect(bindings[2].commandId, 'jumpToNextSnippetPlaceholder');
    expect(bindings[3].args, isA<Map>());
  });

  test('parses package.json contributes', () {
    final file = File('${fixtures.path}/package_contributes.json');
    final contrib = VscCommandsLoader.loadContributionsFile(file);

    expect(contrib.commands, hasLength(2));
    expect(contrib.keybindings, hasLength(1));

    final hello = contrib.commandById('extension.sayHello')!;
    expect(hello.paletteLabel, 'Demo: Say Hello');
    expect(hello.icon, isA<VscCommandProductIcon>());
    expect(hello.enablement, 'editorTextFocus');

    final localized = contrib.commands[1];
    expect(localized.title.text, 'Привет');
    expect(localized.title.original, 'Hello');
    expect(localized.icon, isA<VscCommandThemeIcon>());

    final kb = contrib.keybindings.single;
    expect(kb.keyForPlatform('macos'), 'cmd+f1');
    expect(kb.keyForPlatform('windows'), 'ctrl+f1');
  });
}
