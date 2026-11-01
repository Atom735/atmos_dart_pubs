# atmos_web_indexeddb_api

Dart bindings for the browser **[IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)** by [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

Low-level wrappers over `indexedDB`: databases, transactions, object stores,
indexes, cursors, and key ranges. `IDBRequest` results are `Future`s. Built on
[`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Install

```yaml
dependencies:
  atmos_web_indexeddb_api: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_web_indexeddb_api/atmos_web_indexeddb_api.dart';

Future<void> saveNote() async {
  if (!isIndexedDbSupported) return;
  final db = await openIndexedDb(
    'notes',
    version: 1,
    onUpgradeNeeded: (change) {
      change.database.createObjectStore(
        'notes',
        keyPath: 'id',
        autoIncrement: true,
      );
    },
  );
  final tx = db.transaction('notes', mode: IdbTransactionMode.readwrite);
  final key = await tx.objectStore('notes').put({'title': 'Hello'});
  await tx.completed;
  db.close();
  print(key);
}
```

## Transactions

A transaction commits when the browser returns to the event loop and no
IndexedDB request is still running. `await` on a request from this package
continues inside that request's success turn, so the next `get` / `put` /
`next` on the same transaction is safe.

Do not `await` timers, network, or other futures between requests on an open
transaction — the browser will commit it and the next call throws
`TransactionInactiveError`.

A failed request completes its future with `IndexedDbException` and does not
abort the transaction. Call `transaction.abort()` to roll back.

Inside `onUpgradeNeeded`, create object stores synchronously. Only `await`
IndexedDB requests on `change.transaction`.

## Values

Records are structured-cloned. Maps, lists, numbers, strings, bools,
`DateTime`, and `Uint8List` are converted on the way in and out. Keys and
ranges follow the IndexedDB key rules (`cmp`, `IdbKeyRange`).

## Platform

IndexedDB is part of every current browser, including workers
(`globalThis.indexedDB`). On the VM `isIndexedDbSupported` is false and calls
throw `IndexedDbUnsupportedException`. `IdbFactory.databases` is not
implemented in every browser and throws `IndexedDbException` there.

## License

MIT — see [LICENSE](LICENSE).
