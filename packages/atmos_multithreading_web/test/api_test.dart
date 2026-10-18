import 'package:atmos_multithreading_web/atmos_multithreading_web.dart';
import 'package:atmos_web_worker/atmos_web_worker.dart';
import 'package:test/test.dart';

void main() {
  test('factory throws on VM without Worker', () {
    expect(isWebWorkerSupported, isFalse);
    expect(
      () => WebWorkerParallelExecutor(scriptUrl: 'w.js'),
      throwsUnsupportedError,
    );
  });
}
