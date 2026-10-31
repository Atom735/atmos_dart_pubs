import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:test/test.dart';

void main() {
  test('VscCommand.fromJson requires command and title', () {
    expect(
      () => VscCommand.fromJson({'title': 'X'}),
      throwsFormatException,
    );
    expect(
      () => VscCommand.fromJson({'command': 'a.b'}),
      throwsFormatException,
    );
  });

  test('paletteLabel without category', () {
    final cmd = VscCommand.fromJson({
      'command': 'a.b',
      'title': 'Run',
    });
    expect(cmd.paletteLabel, 'Run');
  });
}
