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

    test('maps punctuation literals used in dumps', () {
      expect(VscKeyStrokeParser.parsePart('ctrl+/').key, 'slash');
      expect(VscKeyStrokeParser.parsePart('ctrl+[').key, 'bracketleft');
      expect(VscKeyStrokeParser.parsePart('ctrl+]').key, 'bracketright');
      expect(VscKeyStrokeParser.parsePart('ctrl+-').key, 'minus');
      expect(VscKeyStrokeParser.parsePart('ctrl+=').key, 'equal');
      expect(VscKeyStrokeParser.parsePart('ctrl+;').key, 'semicolon');
      expect(VscKeyStrokeParser.parsePart('ctrl+.').key, 'period');
      expect(VscKeyStrokeParser.parsePart('ctrl+,').key, 'comma');
      expect(VscKeyStrokeParser.parsePart(r'ctrl+\').key, 'backslash');
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

    test('boolean literals and numeric compare', () {
      expect(VscWhenEvaluator.evaluate('true', {}), isTrue);
      expect(VscWhenEvaluator.evaluate('false', {}), isFalse);
      expect(
        VscWhenEvaluator.evaluate('n > 5', {'n': 3}),
        isFalse,
      );
      expect(
        VscWhenEvaluator.evaluate('n >= 3', {'n': 3}),
        isTrue,
      );
      expect(
        VscWhenEvaluator.evaluate('n < 1', {'n': 0}),
        isTrue,
      );
    });

    test('regex =~ /pattern/', () {
      expect(
        VscWhenEvaluator.evaluate(
          r'resource =~ /foo\/bar/i',
          {'resource': 'Foo/Bar'},
        ),
        isTrue,
      );
      expect(
        VscWhenEvaluator.evaluate(
          "name =~ 'sub'",
          {'name': 'substring'},
        ),
        isTrue,
      );
    });

    test('unknown trailing ops fail closed', () {
      expect(
        VscWhenEvaluator.evaluate('n ??? 1', {'n': 1}),
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

    test('replaceBindings and bindingsForCommand', () {
      final engine = VscKeybindingEngine(
        bindings: const [
          VscKeybinding(key: 'ctrl+s', command: 'save.v1'),
        ],
      );
      expect(engine.bindingsForCommand('save.v1'), hasLength(1));

      engine.replaceBindings(const [
        VscKeybinding(key: 'ctrl+s', command: 'save.v2'),
      ]);
      expect(
        engine
            .handleKey(const VscKeyStroke(key: 's', control: true))
            ?.commandId,
        'save.v2',
      );
      expect(engine.bindingsForCommand('save.v1'), isEmpty);
    });

    test('indexes punctuation dump keys without skip', () {
      final engine = VscKeybindingEngine(
        bindings: const [
          VscKeybinding(key: 'ctrl+/', command: 'editor.action.commentLine'),
        ],
      );
      expect(engine.skippedBindings, isEmpty);
      expect(
        engine
            .handleKey(const VscKeyStroke(key: 'slash', control: true))
            ?.commandId,
        'editor.action.commentLine',
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

      final engine = VscKeybindingEngine(
        bindings: bindings,
        platform: VscKeyPlatform.windows,
      );
      // Punctuation aliases should keep skipped near zero for stock dumps.
      expect(engine.skippedBindings.length, lessThan(20));
    });

    test('loads windows negative dump', () {
      final bindings = VscKeybindingsLoader.loadBundled(
        VscBundledKeybindings.windowsNegative,
        packageRoot: '.',
      );
      expect(bindings.length, greaterThan(500));
      expect(
        bindings.every((b) => b.isRemoval || b.command.startsWith('-')),
        isTrue,
      );
    });
  });
}
