import 'package:atmos_vsc_commands_flutter/atmos_vsc_commands_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toSingleActivator uses keybindings parser', () {
    const binding = VscKeybinding(key: 'ctrl+f1', command: 'demo.f1');
    final activator = binding.toSingleActivator(platform: 'windows');
    expect(activator, isNotNull);
    expect(activator!.trigger, LogicalKeyboardKey.f1);
    expect(activator.control, isTrue);
  });

  test('punctuation key maps via keybindings aliases', () {
    const binding = VscKeybinding(key: 'ctrl+/', command: 'editor.comment');
    final activator = binding.toSingleActivator(platform: 'windows');
    expect(activator, isNotNull);
    expect(activator!.trigger, LogicalKeyboardKey.slash);
  });

  test('builds shortcuts map skipping chords and removals', () {
    final bindings = VscCommandsLoader.parseKeybindings(r'''
    [
      { "key": "ctrl+p", "command": "workbench.action.quickOpen" },
      { "key": "ctrl+k ctrl+c", "command": "editor.action.addCommentLine" },
      { "key": "tab", "command": "-jumpToNextSnippetPlaceholder" }
    ]
    ''');
    final map = VscShortcuts.build(bindings, platform: 'windows');
    expect(map.shortcuts, hasLength(1));
    expect(map.skippedChords, hasLength(1));
    expect(map.skippedRemovals, hasLength(1));
  });
}
