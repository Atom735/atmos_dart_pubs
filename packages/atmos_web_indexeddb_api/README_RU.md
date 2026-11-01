# atmos_web_indexeddb_api

Dart-привязки браузерного **[IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)** от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

Низкоуровневые обёртки над `indexedDB`: базы, транзакции, object store,
индексы, курсоры и диапазоны ключей. Результаты `IDBRequest` — это `Future`.
Построены на [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Установка

```yaml
dependencies:
  atmos_web_indexeddb_api: ^0.1.0
```

## Быстрый старт

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

## Транзакции

Транзакция коммитится, когда браузер возвращается в цикл событий и ни один
запрос IndexedDB ещё не выполняется. `await` запроса из этого пакета
продолжается внутри success-хода этого запроса, поэтому следующий `get` /
`put` / `next` в той же транзакции безопасен.

Не делайте `await` таймеров, сети и других future между запросами открытой
транзакции — браузер её закоммитит, и следующий вызов бросит
`TransactionInactiveError`.

Неудачный запрос завершает свой future с `IndexedDbException` и не отменяет
транзакцию. Чтобы откатить её, вызовите `transaction.abort()`.

В `onUpgradeNeeded` object store создаются синхронно. `await` допустим только
для запросов IndexedDB на `change.transaction`.

## Значения

Записи проходят structured clone. Map, list, числа, строки, bool, `DateTime`
и `Uint8List` конвертируются в обе стороны. Ключи и диапазоны следуют правилам
ключей IndexedDB (`cmp`, `IdbKeyRange`).

## Платформа

IndexedDB есть во всех современных браузерах, включая воркеры
(`globalThis.indexedDB`). На VM `isIndexedDbSupported` равен false, и вызовы
бросают `IndexedDbUnsupportedException`. `IdbFactory.databases` есть не везде
и тогда бросает `IndexedDbException`.

## Лицензия

MIT — см. [LICENSE](LICENSE).
