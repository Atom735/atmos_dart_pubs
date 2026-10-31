import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:test/test.dart';

void main() {
  test('parseContributions resolves %nls% keys', () {
    final nls = VscNlsBundle(
      defaults: VscNlsLoader.parseTable('''
      {
        "ext.hello.title": "Hello",
        "ext.hello.category": "Demo"
      }
      '''),
    )..addTable(
        VscNlsLoader.parseTable(
          '{ "ext.hello.title": "Привет" }',
          locale: VscLocale('ru'),
        ),
      );

    final contrib = VscCommandsLoader.parseContributions(
      '''
      {
        "contributes": {
          "commands": [
            {
              "command": "ext.hello",
              "title": "%ext.hello.title%",
              "category": "%ext.hello.category%"
            }
          ]
        }
      }
      ''',
      nls: nls,
      locale: VscLocale('ru'),
    );

    final cmd = contrib.commands.single;
    expect(cmd.title.value, 'Привет');
    expect(cmd.title.original, 'Hello');
    expect(cmd.category?.text, 'Demo');
    expect(cmd.paletteLabel, 'Demo: Привет');
  });
}
