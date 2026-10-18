import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';
import 'package:test/test.dart';

void main() {
  test('jsInteropSupported is false on VM', () {
    expect(jsInteropSupported, isFalse);
  });

  test('API throws UnsupportedError on VM', () {
    expect(() => jsGlobal('window'), throwsUnsupportedError);
  });
}
