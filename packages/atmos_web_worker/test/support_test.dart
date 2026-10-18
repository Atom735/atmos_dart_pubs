import 'package:atmos_web_worker/atmos_web_worker.dart';
import 'package:test/test.dart';

void main() {
  test('Worker unsupported on VM', () {
    expect(isWebWorkerSupported, isFalse);
    expect(() => WebWorker('x.js'), throwsUnsupportedError);
  });
}
