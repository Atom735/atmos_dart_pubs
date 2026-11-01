import 'dart:typed_data';

import 'package:atmos_web_indexeddb_api/atmos_web_indexeddb_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'put, index, cursor, and key range',
    () async {
      final name = 'atmos_idb_${DateTime.now().microsecondsSinceEpoch}';
      IdbDatabase? db;
      addTearDown(() async {
        db?.close();
        await deleteIndexedDb(name);
      });

      var oldVersion = -1;
      var newVersion = -1;
      db = await openIndexedDb(
        name,
        version: 1,
        onUpgradeNeeded: (change) {
          oldVersion = change.oldVersion;
          newVersion = change.newVersion;
          final store = change.database.createObjectStore(
            'items',
            keyPath: 'id',
          );
          store.createIndex('byName', 'name', unique: true);
        },
      );

      expect(oldVersion, 0);
      expect(newVersion, 1);

      expect(db.name, name);
      expect(db.version, 1);
      expect(db.objectStoreNames, ['items']);
      expect(indexedDb.cmp(1, 2), -1);

      final range = IdbKeyRange.bound(1, 3, upperOpen: true);
      expect(range.includes(1), isTrue);
      expect(range.includes(3), isFalse);
      expect(range.lower, 1);
      expect(range.upper, 3);
      expect(range.upperOpen, isTrue);

      final at = DateTime.utc(2026, 11, 1);
      final bytes = Uint8List.fromList(<int>[9, 8, 7]);
      final write = db.transaction(
        'items',
        mode: IdbTransactionMode.readwrite,
      );
      final store = write.objectStore('items');
      await store.put({
        'id': 1,
        'name': 'a',
        'at': at,
        'bytes': bytes,
      });
      await store.put({'id': 2, 'name': 'b'});
      await store.put({'id': 3, 'name': 'c'});
      await expectLater(
        store.put({'id': 4, 'name': 'a'}),
        throwsA(
          isA<IndexedDbException>().having(
            (error) => error.name,
            'name',
            'ConstraintError',
          ),
        ),
      );
      expect(await store.count(), 3);
      await write.completed;

      final read = db.transaction(['items']);
      final items = read.objectStore('items');
      final byName = items.index('byName');
      expect(byName.unique, isTrue);
      final row = await byName.get('b');
      expect(row, {'id': 2, 'name': 'b'});

      final saved = (await items.get(1))! as Map<Object?, Object?>;
      expect(saved['at'], at);
      expect(saved['bytes'], bytes);
      final page = await items.getAll(range);
      expect(page, [
        {'id': 1, 'name': 'a', 'at': at, 'bytes': bytes},
        {'id': 2, 'name': 'b'},
      ]);

      final seen = <Object?>[];
      var cursor = await items.openCursor(
        direction: IdbCursorDirection.prev,
      );
      while (cursor != null) {
        seen.add(cursor.primaryKey);
        cursor = await cursor.next();
      }
      expect(seen, [3, 2, 1]);
      await read.completed;

      try {
        final listed = await indexedDb.databases();
        expect(listed.map((info) => info.name), contains(name));
      } on IndexedDbException {
        // databases() is missing in some browsers.
      }
    },
    testOn: 'browser',
  );
}
