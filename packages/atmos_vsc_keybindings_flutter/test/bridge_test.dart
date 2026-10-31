import 'package:atmos_vsc_keybindings_flutter/atmos_vsc_keybindings_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fromKeyEvent maps ctrl+s', () {
    final stroke = VscFlutterKeyBridge.fromKeyEvent(
      logicalKey: LogicalKeyboardKey.keyS,
      pressed: {
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.keyS,
      },
    );
    expect(stroke, isNotNull);
    expect(stroke!.control, isTrue);
    expect(stroke.key, 's');
  });

  test('toSingleActivator round-trips letter', () {
    const stroke = VscKeyStroke(key: 'p', control: true, shift: true);
    final a = VscFlutterKeyBridge.toSingleActivator(stroke);
    expect(a, isNotNull);
    expect(a!.trigger, LogicalKeyboardKey.keyP);
    expect(a.control, isTrue);
    expect(a.shift, isTrue);
  });

  test('loads windows asset', () async {
    final bindings = await VscKeybindingsAssetLoader.loadPlatform(
      VscKeyPlatform.windows,
    );
    expect(bindings.length, greaterThan(500));
  }, timeout: const Timeout(Duration(seconds: 30)),);
}
