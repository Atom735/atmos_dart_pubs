import 'package:atmos_vscode_theme/atmos_vscode_theme.dart';
import 'package:test/test.dart';

void main() {
  group('jsoncDecode (via atmos_jsonc)', () {
    test('strips line comments', () {
      final v = jsoncDecode('{"a": 1, // comment\n"b": 2}');
      expect(v, {'a': 1, 'b': 2});
    });

    test('trailing commas', () {
      final v = jsoncDecode('{"a": [1, 2,], "b": {"c": 3,},}');
      expect(v, {
        'a': [1, 2],
        'b': {'c': 3},
      });
    });
  });
}
