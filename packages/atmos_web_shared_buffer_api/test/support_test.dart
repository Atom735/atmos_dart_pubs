import 'package:atmos_web_shared_buffer_api/atmos_web_shared_buffer_api.dart';
import 'package:test/test.dart';

void main() {
  test('SAB unsupported on VM', () {
    expect(isSharedArrayBufferSupported, isFalse);
    expect(isAtomicsSupported, isFalse);
  });

  test('construct throws on VM', () {
    expect(() => SharedArrayBuffer(4), throwsUnsupportedError);
  });
}
