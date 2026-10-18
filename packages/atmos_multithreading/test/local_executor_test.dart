import 'package:atmos_multithreading/atmos_multithreading.dart';
import 'package:test/test.dart';

void main() {
  test('runs registered job', () async {
    final pool = LocalParallelExecutor({
      'double': (input) => (input! as int) * 2,
    });
    expect(await pool.run('double', 21), 42);
    await pool.close();
  });

  test('unknown job throws', () async {
    final pool = LocalParallelExecutor({});
    expect(
      () => pool.run('missing', null),
      throwsA(isA<ParallelException>()),
    );
    await pool.close();
  });
}
