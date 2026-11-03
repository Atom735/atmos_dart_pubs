import 'package:atmos_web_worker_scope/atmos_web_worker_scope.dart';
import 'package:test/test.dart';

void main() {
  test('the VM is not a dedicated worker', () {
    expect(isDedicatedWorkerScope, isFalse);
    expect(WorkerScope.current, isNull);
  });
}
