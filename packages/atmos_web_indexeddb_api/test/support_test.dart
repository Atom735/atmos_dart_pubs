import 'package:atmos_web_indexeddb_api/atmos_web_indexeddb_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'IndexedDB is unsupported on the VM',
    () {
      expect(isIndexedDbSupported, isFalse);
    },
    testOn: 'vm',
  );

  test(
    'factory throws when unsupported',
    () {
      expect(() => indexedDb, throwsA(isA<IndexedDbUnsupportedException>()));
    },
    testOn: 'vm',
  );

  test(
    'open throws when unsupported',
    () {
      expect(
        openIndexedDb('notes'),
        throwsA(isA<IndexedDbUnsupportedException>()),
      );
    },
    testOn: 'vm',
  );

  test(
    'key range throws when unsupported',
    () {
      expect(
        () => IdbKeyRange.only(1),
        throwsA(isA<IndexedDbUnsupportedException>()),
      );
    },
    testOn: 'vm',
  );

  test('wire names match the IndexedDB spec', () {
    expect(IdbCursorDirection.nextUnique.jsName, 'nextunique');
    expect(IdbCursorDirection.prevUnique.jsName, 'prevunique');
    expect(IdbTransactionMode.readwrite.jsName, 'readwrite');
    expect(IdbTransactionMode.versionchange.jsName, 'versionchange');
    expect(IdbDurability.browserDefault.jsName, 'default');
    expect(IdbDurability.relaxed.jsName, 'relaxed');
  });
}
