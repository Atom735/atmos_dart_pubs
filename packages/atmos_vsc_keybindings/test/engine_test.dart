import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:test/test.dart';

void main() {
  group('VscKeyStrokeParser', () {
    test('parses modifiers and trigger', () {
      final s = VscKeyStrokeParser.parsePart('ctrl+shift+p');
      expect(s.control, isTrue);
      expect(s.shift, isTrue);
      expect(s.key, 'p');
      expect(s.toKeyString(), 'ctrl+shift+p');
    });

    test('parses chords', () {
      final parts = VscKeyStrokeParser.parse('ctrl+k ctrl+c');
      expect(parts, hasLength(2));
      expect(parts[0].key, 'k');
      expect(parts[1].key, 'c');
    });
  });

  group('VscWhenEvaluator', () {
    test('and / not / equality', () {
      final ctx = <String, Object?>{
        'editorTextFocus': true,
        'resourceScheme': 'file',
      };
      expect(
        VscWhenEvaluator.evaluate(
          "editorTextFocus && resourceScheme == 'file'",
          ctx,
        ),
        isTrue,
      );
      expect(
        VscWhenEvaluator.evaluate('!editorTextFocus', ctx),
        isFalse,
      );
    });
  });

  group('VscKeybindingEngine', () {
    test('resolves single key with when', () {
      final engine = VscKeybindingEngine(
        bindings: const [
          VscKeybinding(
            key: 'ctrl+s',
            command: 'workbench.action.files.save',
            when: 'editorTextFocus',
          ),
        ],
        context: {'editorTextFocus': true},
      );

      final match = engine.handleKey(
        const VscKeyStroke(key: 's', control: true),
      );
      expect(match?.commandId, 'workbench.action.files.save');
    });

    test('skips when when-clause fails', () {
      final engine = VscKeybindingEngine(
        bindings: const [
          VscKeybinding(
            key: 'ctrl+s',
            command: 'workbench.action.files.save',
            when: 'editorTextFocus',
          ),
        ],
        context: {'editorTextFocus': false},
      );
      expect(
        engine.handleKey(const VscKeyStroke(key: 's', control: true)),
        isNull,
      );
    });

    test('handles two-step chord', () {
      final engine = VscKeybindingEngine(
        bindings: const [
          VscKeybinding(
            key: 'ctrl+k ctrl+c',
            command: 'editor.action.addCommentLine',
          ),
        ],
      );

      expect(
        engine.handleKey(const VscKeyStroke(key: 'k', control: true)),
        isNull,
      );
      expect(engine.inChord, isTrue);

      final match = engine.handleKey(
        const VscKeyStroke(key: 'c', control: true),
      );
      expect(match?.commandId, 'editor.action.addCommentLine');
      expect(engine.inChord, isFalse);
    });

    test('user override wins over default', () {
      final engine = VscKeybindingEngine.merge(
        defaults: const [
          VscKeybinding(key: 'ctrl+s', command: 'save.default'),
        ],
        user: const [
          VscKeybinding(key: 'ctrl+s', command: 'save.user'),
        ],
      );
      expect(
        engine
            .handleKey(const VscKeyStroke(key: 's', control: true))
            ?.commandId,
        'save.user',
      );
    });

    test('removal drops default', () {
      final engine = VscKeybindingEngine.merge(
        defaults: const [
          VscKeybinding(key: 'ctrl+s', command: 'save.default'),
        ],
        user: const [
          VscKeybinding(key: 'ctrl+s', command: '-save.default'),
        ],
      );
      expect(
        engine.handleKey(const VscKeyStroke(key: 's', control: true)),
        isNull,
      );
    });
  });

  group('bundled assets', () {
    test('loads windows dump from package checkout', () {
      final bindings = VscKeybindingsLoader.loadBundledPlatform(
        VscKeyPlatform.windows,
        packageRoot: '.',
      );
      expect(bindings.length, greaterThan(500));
      expect(
        bindings.any((b) => b.command.contains('workbench.action')),
        isTrue,
      );
    });
  });
}
