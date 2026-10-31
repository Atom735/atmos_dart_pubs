import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:test/test.dart';

void main() {
  group('VscCommandService', () {
    test('execute runs handler with args', () async {
      final service = VscCommandService();
      Object? seenArgs;
      service.register('demo.run', (inv) {
        seenArgs = inv.args;
        return 'ok';
      });

      expect(await service.execute('demo.run', args: {'x': 1}), 'ok');
      expect(seenArgs, {'x': 1});
    });

    test('canExecute respects enablement', () {
      final service = VscCommandService(
        context: {'editorTextFocus': false},
      );
      service.registerMetadata(const [
        VscCommand(
          command: 'demo.run',
          title: VscLocalizedString('Run'),
          enablement: 'editorTextFocus',
        ),
      ]);
      service.register('demo.run', (_) => null);

      expect(service.canExecute('demo.run'), isFalse);
      service.context['editorTextFocus'] = true;
      expect(service.canExecute('demo.run'), isTrue);
    });

    test('executeMatch uses keybinding args', () async {
      final service = VscCommandService();
      Object? seen;
      service.register('demo.run', (inv) {
        seen = inv.args;
        return null;
      });

      const binding = VscKeybinding(
        key: 'ctrl+s',
        command: 'demo.run',
        args: 'from-key',
      );
      await service.executeMatch(
        const VscKeyMatch(
          commandId: 'demo.run',
          binding: binding,
          args: 'from-key',
        ),
      );
      expect(seen, 'from-key');
    });

    test('createEngine shares context with when', () {
      final service = VscCommandService(
        context: {'editorTextFocus': true},
      );
      final engine = service.createEngine(
        defaults: const [
          VscKeybinding(
            key: 'ctrl+s',
            command: 'demo.save',
            when: 'editorTextFocus',
          ),
        ],
      );
      service.context['editorTextFocus'] = false;
      expect(
        engine.handleKey(const VscKeyStroke(key: 's', control: true)),
        isNull,
      );
      service.context['editorTextFocus'] = true;
      expect(
        engine
            .handleKey(const VscKeyStroke(key: 's', control: true))
            ?.commandId,
        'demo.save',
      );
    });

    test('missing handler throws', () {
      final service = VscCommandService();
      expect(
        () => service.execute('missing'),
        throwsA(isA<VscCommandException>()),
      );
    });
  });
}
